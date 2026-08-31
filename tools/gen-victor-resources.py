#!/usr/bin/env python3
"""Generate the wheel `resource` stanzas for Formula/victor.rb.

The victor formula installs victor-ai itself from its audited PyPI sdist (the
`url`/`sha256` the update workflow rewrites) but its ~70-dependency closure
must ship as pinned **wheel** resources — building orjson/pydantic-core/tiktoken
et al. from sdists would require a Rust toolchain on every user machine.

Usage (from a checkout of this tap, with any Python 3.12 and network):

    python3 -m venv /tmp/resolve-venv
    /tmp/resolve-venv/bin/pip install --dry-run --quiet \
        --report /tmp/victor-resolve.json victor-ai==<VERSION>
    python3 tools/gen-victor-resources.py \
        --report /tmp/victor-resolve.json \
        --manifest tools/victor-resources.json \
        > /tmp/victor-resources.rb

Then paste the emitted blocks into Formula/victor.rb between `depends_on`
and `def install`, replacing the previous block. The manifest records every
selection so the next regeneration diffs cleanly.

Wheel selection per package: one resource for pure-Python wheels; for binary
wheels one per supported platform (macOS arm64, macOS x86_64, Linux x86_64),
each downloaded and sha256'd from the real bytes — never copied from metadata.
"""

import argparse
import base64
import hashlib
import json
import pathlib
import re
import sys
import urllib.request
from typing import Any

PYPI = "https://pypi.org/pypi/{name}/{version}/json"

# abi preference inside one platform bucket: cp312 first, then abi3, then none.
ABI_RANK = [("cp312", 0), ("abi3", 1), ("none", 2)]


def sha256_of(path: pathlib.Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1 << 20), b""):
            digest.update(chunk)
    return digest.hexdigest()


def fetch(url: str, cache: pathlib.Path) -> pathlib.Path:
    cache.mkdir(parents=True, exist_ok=True)
    target = cache / url.rsplit("/", 1)[-1]
    if not target.exists():
        with urllib.request.urlopen(url, timeout=120) as response:
            target.write_bytes(response.read())
    return target


def parse_wheel(filename: str) -> tuple[str, list[str], list[str]] | None:
    """Return (python_tag, abi_tags, platform_tags) for a wheel filename."""
    stem = filename[:-4] if filename.endswith(".whl") else ""
    parts = stem.split("-")
    if len(parts) == 5:
        _, _, python, abi, plat = parts
    elif len(parts) == 6:  # build tag present
        _, _, _, python, abi, plat = parts
    else:
        return None
    return python, abi.split("."), plat.split(".")


def classify(filename: str) -> tuple[set[str], int] | None:
    """Map a wheel filename to (buckets served, abi_rank); None if unusable."""
    parsed = parse_wheel(filename)
    if parsed is None:
        return None
    python, abis, plats = parsed
    for tag, rank in ABI_RANK:
        if tag in abis:
            abi_rank = rank
            break
    else:
        if any(a.endswith("abi3") for a in abis):
            abi_rank = 1
        elif "none" in abis:
            abi_rank = 2
        else:
            return None  # some other cpXY ABI we cannot use with 3.12
    buckets: set[str] = set()
    for tag in plats:
        if tag == "any":
            if python.startswith("py"):
                buckets.add("pure")
        elif tag.startswith("macosx"):
            if tag.endswith("arm64"):
                buckets.add("mac_arm")
            elif tag.endswith("x86_64"):
                buckets.add("mac_x64")
            elif tag.endswith("universal2"):
                buckets.update({"mac_arm", "mac_x64"})
        elif tag.startswith("manylinux") or tag == "linux_x86_64":
            if tag.endswith("x86_64"):
                buckets.add("linux_x64")
    if not buckets:
        return None  # win*, musllinux, aarch64-linux, …
    return buckets, abi_rank


def best(files: list[dict[str, Any]], bucket: str) -> dict[str, Any] | None:
    candidates = []
    for entry in files:
        kind = classify(entry["filename"])
        if kind and bucket in kind[0]:
            candidates.append((kind[1], entry["filename"], entry))
    if not candidates:
        return None
    candidates.sort(key=lambda item: (item[0], item[1]))
    return candidates[0][2]


BUCKETS = ["pure", "mac_arm", "mac_x64", "linux_x64"]


def emit(picks_by_name: list[tuple[str, dict[str, dict[str, Any]]]], digests: dict[str, str]) -> str:
    """Emit one `resource` block per package with per-platform url/sha256 legs
    (the homebrew-core canonical shape: on_macos/on_linux + on_arm/on_intel
    inside the resource, each carrying exactly url+sha256)."""

    def url_sha(res: dict[str, Any], indent: str) -> list[str]:
        return [
            indent + 'url "%s"' % res["url"],
            indent + 'sha256 "%s"' % digests[res["url"]],
        ]

    lines: list[str] = []
    for _, picks in picks_by_name:
        project = next(iter(picks.values()))["project"]
        lines.append('resource "%s" do' % project)
        if "pure" in picks:
            lines.extend(url_sha(picks["pure"], "  "))
        else:
            mac_legs = [(a, b) for a, b in [("on_arm do", "mac_arm"), ("on_intel do", "mac_x64")] if b in picks]
            if mac_legs:
                lines.append("  on_macos do")
                for arch, bucket in mac_legs:
                    lines.append("    " + arch)
                    lines.extend(url_sha(picks[bucket], "      "))
                    lines.append("    end")
                lines.append("  end")
            if "linux_x64" in picks:
                lines.append("  on_linux do")
                lines.append("    on_intel do")
                lines.extend(url_sha(picks["linux_x64"], "      "))
                lines.append("    end")
                lines.append("  end")
        lines.append("end")
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--report", required=True, help="pip install --dry-run --report JSON")
    parser.add_argument("--manifest", required=True, help="output JSON manifest path")
    parser.add_argument("--cache", default="/tmp/victor-wheel-cache")
    args = parser.parse_args()

    report = json.load(open(args.report))
    packages = []
    for item in report["install"]:
        info = item["metadata"]
        packages.append((info["name"], info["version"]))
    packages.sort(key=lambda pair: pair[0].lower().replace("-", "_"))

    cache = pathlib.Path(args.cache)
    manifest: dict[str, Any] = {}
    picks_by_name: list[tuple[str, dict[str, dict[str, Any]]]] = []

    for name, version in packages:
        url = PYPI.format(name=re.sub(r"[-_.]+", "-", name), version=version)
        with urllib.request.urlopen(url, timeout=60) as response:
            payload = json.load(response)
        files = payload["urls"]
        picks: dict[str, dict[str, Any]] = {}
        for bucket in BUCKETS:
            chosen = best(files, bucket)
            if chosen:
                real = fetch(chosen["url"], cache)
                digests = manifest.setdefault("_digests", {})
                digests[chosen["url"]] = sha256_of(real)
                picks[bucket] = {"project": re.sub(r"[-_.]+", "-", name).lower(), "url": chosen["url"], "filename": chosen["filename"]}
        if not picks:
            print(f"ERROR: no usable wheel for {name} {version}", file=sys.stderr)
            return 1
        missing = [b for b in BUCKETS if b not in picks]
        if missing:
            print(f"note: {name} {version} has no wheel for {missing}", file=sys.stderr)
        manifest[name] = {"version": version, **{b: p["filename"] for b, p in picks.items()}}
        picks_by_name.append((name, picks))

    pathlib.Path(args.manifest).write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n")
    sys.stdout.write(emit(picks_by_name, manifest["_digests"]))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
