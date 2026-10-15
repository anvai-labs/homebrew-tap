#!/usr/bin/env python3
"""Audit stable upstream releases; --dispatch queues existing bump workflows.

Read-only by default. Never merges PRs, changes tags, or installs packages.
"""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
PRODUCTS = ("sandhi", "sentinelpass", "agentbrowser", "inferflux", "victor")


def version(value):
    if not re.fullmatch(r"v?(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)", value):
        raise ValueError(f"expected stable X.Y.Z version: {value!r}")
    return tuple(map(int, value.removeprefix("v").split(".")))


def current_versions(product, root=ROOT):
    text = (root / "Formula" / f"{product}.rb").read_text()
    pattern = r"victor_ai-([0-9.]+)\.tar\.gz" if product == "victor" else r"releases/download/(v[^/]+)/"
    versions = set(re.findall(pattern, text))
    if len(versions) != 1:
        raise ValueError(f"{product}: expected one formula version, got {versions}")
    values = list(versions)
    if product == "sentinelpass":
        cask = (root / "Casks/sentinelpass.rb").read_text()
        values += re.findall(r'^\s*version "([^"]+)"', cask, re.MULTILINE)
        if len(values) != 2:
            raise ValueError("sentinelpass: expected one cask version")
    for value in values:
        version(value)
    return values


def release_version(product, metadata):
    if product == "victor":
        latest = metadata["info"]["version"]
        if not any(f["packagetype"] == "sdist" and not f.get("yanked") for f in metadata["urls"]):
            raise ValueError("Victor release has no non-yanked sdist")
    else:
        if metadata["draft"] or metadata["prerelease"]:
            raise ValueError(f"{product}: latest release is not stable/public")
        latest = metadata["tag_name"]
    version(latest)
    return latest


def needs_update(current, latest):
    target = version(latest)
    if any(version(value) > target for value in current):
        raise ValueError(f"refusing downgrade from {current} to {latest}")
    return any(version(value) < target for value in current)


def dispatch_command(product, latest):
    workflow = "update-formula.yml" if product == "victor" else f"update-{product}.yml"
    field = "version" if product == "victor" else "tag"
    return ["gh", "workflow", "run", workflow, "--repo",
            os.environ.get("GITHUB_REPOSITORY", "anvai-labs/homebrew-tap"),
            "--ref", "main", "-f", f"{field}={latest}"]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dispatch", action="store_true")
    args = parser.parse_args()
    failures = []
    report = ["| Product | Tap | Upstream | Action |", "|---|---|---|---|"]
    for product in PRODUCTS:
        try:
            current = current_versions(product)
            if product == "victor":
                with urllib.request.urlopen("https://pypi.org/pypi/victor-ai/json", timeout=30) as response:
                    metadata = json.load(response)
            else:
                metadata = json.loads(subprocess.check_output(
                    ["gh", "api", f"repos/anvai-labs/{product}/releases/latest"], text=True, timeout=60))
            latest = release_version(product, metadata)
            changed = needs_update(current, latest)
            action = "update available" if changed else "aligned"
            if changed and args.dispatch:
                subprocess.run(dispatch_command(product, latest), check=True, timeout=60)
                action = "bump workflow dispatched (merge remains gated)"
            report.append(f"| {product} | {', '.join(current)} | {latest} | {action} |")
        except (ValueError, KeyError, OSError, subprocess.SubprocessError) as error:
            failures.append(f"{product}: {error}")
            report.append(f"| {product} | — | — | FAILED: {error} |")
    rendered = "\n".join(report) + "\n"
    print(rendered)
    if os.environ.get("GITHUB_STEP_SUMMARY"):
        with open(os.environ["GITHUB_STEP_SUMMARY"], "a") as summary:
            summary.write(rendered)
    if failures:
        raise SystemExit("\n".join(failures))


if __name__ == "__main__":
    main()
