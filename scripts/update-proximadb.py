#!/usr/bin/env python3
"""Update the Linux server formula using a downloaded, manifest-checked release."""
import argparse
import hashlib
from pathlib import Path
import re
import tempfile
import urllib.request

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tag", required=True)
    args = parser.parse_args()
    if not re.fullmatch(r"v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)", args.tag):
        parser.error("tag must be stable vX.Y.Z")
    version = args.tag[1:]
    path = ROOT / "Formula/proximadb.rb"
    original = path.read_text()
    current = re.search(r"releases/download/v([0-9.]+)/", original).group(1)
    if tuple(map(int, version.split("."))) < tuple(map(int, current.split("."))):
        raise ValueError("Refusing to downgrade ProximaDB")
    base = f"https://github.com/anvai-labs/proximaDB/releases/download/{args.tag}"
    asset = f"proximadb-{version}-x86_64-unknown-linux-gnu.tar.gz"
    with urllib.request.urlopen(f"{base}/SHA256SUMS.txt", timeout=60) as response:
        manifest = response.read().decode()
    expected = [line.split()[0] for line in manifest.splitlines()
                if len(line.split()) == 2 and line.split()[1].lstrip("*") == asset]
    if len(expected) != 1:
        raise ValueError(f"Missing or ambiguous checksum for {asset}")
    digest = hashlib.sha256()
    with tempfile.TemporaryFile() as archive, urllib.request.urlopen(f"{base}/{asset}", timeout=120) as response:
        while chunk := response.read(1024 * 1024):
            archive.write(chunk)
            digest.update(chunk)
    if digest.hexdigest() != expected[0]:
        raise ValueError("Downloaded server archive differs from checksum manifest")
    updated = re.sub(r'^  url ".*"$', f'  url "{base}/{asset}"', original, count=1, flags=re.M)
    updated = re.sub(r'^  sha256 ".*"$', f'  sha256 "{digest.hexdigest()}"', updated, count=1, flags=re.M)
    path.write_text(updated)


if __name__ == "__main__":
    main()
