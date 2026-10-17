#!/usr/bin/env python3
"""Regenerate dq-kernel's release URL and offline Python/Spark resources.

Run with Python 3.12. All hashes come from downloaded bytes. --report can reuse
a pip resolution report; otherwise resolve the released spark/deequ extras.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
SOURCE_ONLY = {"pyhocon", "pyspark"}


def download(url, directory, expected=None):
    path = directory / url.rsplit("/", 1)[-1]
    if not path.exists():
        partial = path.with_suffix(path.suffix + ".partial")
        with urllib.request.urlopen(url, timeout=120) as response, partial.open("wb") as output:
            while chunk := response.read(1024 * 1024):
                output.write(chunk)
        partial.replace(path)
    digest = hashlib.file_digest(path.open("rb"), "sha256").hexdigest()
    if expected and digest != expected:
        raise ValueError(f"Downloaded checksum mismatch: {path.name}")
    return path, digest


def choose_wheels(files):
    """Choose CPython 3.12 wheels for macOS 14+ arm64 and glibc Linux x64."""
    pure = [f for f in files if f["filename"].endswith(("-py3-none-any.whl", "-py2.py3-none-any.whl"))]
    if pure:
        return {"pure": sorted(pure, key=lambda f: f["filename"])[0]}
    picks = {}
    for platform in ("mac", "linux"):
        candidates = []
        for entry in files:
            match = re.search(r"-(cp[0-9]+)-(cp312|abi3)-(.+)\.whl$", entry["filename"])
            if not match:
                continue
            python, abi, tags = match.groups()
            if (abi == "cp312" and python != "cp312") or (abi == "abi3" and int(python[2:]) > 312):
                continue
            for tag in tags.split("."):
                mac = re.fullmatch(r"macosx_(\d+)_(\d+)_(arm64|universal2)", tag)
                linux = re.fullmatch(r"manylinux_(\d+)_(\d+)_x86_64", tag)
                if platform == "mac" and mac and tuple(map(int, mac.groups()[:2])) <= (14, 0):
                    candidates.append(entry)
                elif platform == "linux" and ((linux and tuple(map(int, linux.groups())) <= (2, 35))
                                              or tag == "manylinux2014_x86_64"):
                    candidates.append(entry)
        if not candidates:
            raise ValueError(f"No compatible {platform} wheel")
        picks[platform] = sorted(candidates, key=lambda f: f["filename"])[0]
    return picks


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tag", required=True)
    parser.add_argument("--report", type=Path)
    parser.add_argument("--cache", type=Path, default=Path(tempfile.gettempdir()) / "dq-kernel-brew-assets")
    args = parser.parse_args()
    if not re.fullmatch(r"v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)", args.tag):
        parser.error("tag must be stable vX.Y.Z")
    version = args.tag[1:]
    formula = ROOT / "Formula/dq-kernel.rb"
    original = formula.read_text()
    current = re.search(r"releases/download/v([0-9.]+)/", original).group(1)
    if tuple(map(int, version.split("."))) < tuple(map(int, current.split("."))):
        raise ValueError("Refusing to downgrade dq-kernel")
    args.cache.mkdir(parents=True, exist_ok=True)
    url = f"https://github.com/anvai-labs/dq-kernel/releases/download/{args.tag}/dq_kernel-{version}.tar.gz"
    archive, digest = download(url, args.cache)
    report_path = args.report or args.cache / "resolve.json"
    if not args.report:
        if sys.version_info[:2] != (3, 12):
            raise ValueError("Resolve with Python 3.12 to match the formula")
        subprocess.run([sys.executable, "-m", "pip", "install", "--dry-run", "--ignore-installed",
                        "--report", str(report_path), f"{archive}[spark,deequ]",
                        "setuptools", "wheel", "poetry-core"], check=True)
    report = json.loads(report_path.read_text())
    packages = {re.sub(r"[-_.]+", "-", item["metadata"]["name"]).lower(): item["metadata"]["version"]
                for item in report["install"]}
    if packages.pop("dq-kernel") != version:
        raise ValueError("Resolution report belongs to another dq-kernel version")
    if not {"setuptools", "wheel", "packaging", "poetry-core", "pyspark", "pydeequ"} <= packages.keys():
        raise ValueError("Resolution report lacks the required backends or Spark/Deequ runtime")
    blocks = []
    manifest = {"version": version, "archive": {"url": url, "sha256": digest}, "resources": {}}
    for name, package_version in sorted(packages.items()):
        with urllib.request.urlopen(f"https://pypi.org/pypi/{name}/{package_version}/json", timeout=60) as response:
            metadata = json.load(response)
        files = [f for f in metadata["urls"] if not f.get("yanked")]
        if name in SOURCE_ONLY:
            picks = {"source": next(f for f in files if f["packagetype"] == "sdist")}
        else:
            picks = choose_wheels(files)
        verified = {}
        for platform, entry in picks.items():
            _, sha = download(entry["url"], args.cache, entry["digests"]["sha256"])
            verified[platform] = {"url": entry["url"], "sha256": sha}
        blocks.append(f'  resource "{name}" do')
        for platform, entry in verified.items():
            conditional = platform in {"mac", "linux"}
            indent = "      " if conditional else "    "
            if conditional:
                blocks.append("    on_macos do" if platform == "mac" else "    on_linux do")
            blocks += [f'{indent}url "{entry["url"]}"', f'{indent}sha256 "{entry["sha256"]}"']
            if conditional:
                blocks.append("    end")
        blocks += ["  end", ""]
        manifest["resources"][name] = {"version": package_version, **verified}
        print(f"Verified {name} {package_version}", flush=True)
    updated = re.sub(r'^  url ".*"$', f'  url "{url}"', original, count=1, flags=re.M)
    updated = re.sub(r'^  sha256 ".*"$', f'  sha256 "{digest}"', updated, count=1, flags=re.M)
    start, end = "  # BEGIN GENERATED RESOURCES\n", "  # END GENERATED RESOURCES"
    before, remainder = updated.split(start, 1)
    _, after = remainder.split(end, 1)
    formula.write_text(before + start + "\n".join(blocks) + end + after)
    (ROOT / "tools/dq-kernel-resources.json").write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")


if __name__ == "__main__":
    main()
