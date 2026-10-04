#!/usr/bin/env python3
"""Verify both native Linux binary versions before a Sandhi formula bump.

Use only with a downloaded, trusted Sandhi GitHub release archive. The archive is
never extracted wholesale; only the two known Sandhi binaries are extracted
(release assets shipped alongside them since v0.11.0 are admitted but never
read). Child environment and execution time are bounded. Historical proxy
binaries without --version fail.
"""
import argparse
import os
from pathlib import Path
import re
import subprocess
import tarfile
import tempfile


def verify(archive, tag):
    if not re.fullmatch(r"v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)", tag):
        raise ValueError("expected stable release tag vX.Y.Z")
    with tempfile.TemporaryDirectory(prefix="sandhi-version-check-") as temporary:
        directory = Path(temporary)
        with tarfile.open(archive, "r:gz") as source:
            members = source.getmembers()
            names = {m.name for m in members}
            if not {"sandhi", "sandhi-proxy"} <= names:
                raise ValueError("archive must contain the two Sandhi binaries at its root")
            # Only the two known binaries are ever extracted; other archive
            # members (release assets, docs) are admitted but never read.
            binaries = [m for m in members if m.name in ("sandhi", "sandhi-proxy")]
            if any(not m.isfile() or not 0 < m.size <= 512 * 1024 * 1024 for m in binaries):
                raise ValueError("archive contains unsafe binary entries")
            for member in binaries:
                with source.extractfile(member) as stream, (directory / member.name).open("wb") as output:
                    import shutil
                    shutil.copyfileobj(stream, output)
                (directory / member.name).chmod(0o700)
        environment = {"PATH": os.defpath, "LANG": "C", "SANDHI_BIND": "invalid",
                       "SANDHI_CONFIG": str(directory / "absent.json")}
        for name in ("sandhi", "sandhi-proxy"):
            with tempfile.TemporaryFile() as output:
                try:
                    result = subprocess.run([str(directory / name), "--version"], cwd=directory,
                        env=environment, stdin=subprocess.DEVNULL, stdout=output,
                        stderr=subprocess.DEVNULL, timeout=5, check=False)
                except subprocess.TimeoutExpired:
                    raise ValueError("binary --version timed out") from None
                output.seek(0)
                if result.returncode or output.read(257) != f"{name} {tag[1:]}\n".encode():
                    raise ValueError("binary version does not match release tag")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", type=Path)
    parser.add_argument("tag")
    args = parser.parse_args()
    verify(args.archive, args.tag)
