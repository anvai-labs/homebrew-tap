"""Offline archive admission tests; fixtures are small local executable scripts."""
import importlib.util
import io
from pathlib import Path
import tarfile
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("archive_check", ROOT / "scripts/check-sandhi-archive.py")
checker = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(checker)


class SandhiVersions(unittest.TestCase):
    def archive(self, root, version="0.7.1", proxy_version=None, extra=False, symlink=False):
        archive = root / "release.tgz"
        with tarfile.open(archive, "w:gz") as output:
            for name in ("sandhi", "sandhi-proxy"):
                actual = proxy_version if name == "sandhi-proxy" and proxy_version else version
                data = f'#!/bin/sh\nprintf "{name} {actual}\\n"\n'.encode()
                entry = tarfile.TarInfo(name)
                entry.size = len(data)
                if symlink:
                    entry.type = tarfile.SYMTYPE; entry.linkname = "/bin/sh"
                output.addfile(entry, io.BytesIO(data))
            if extra: output.addfile(tarfile.TarInfo("../unexpected"), io.BytesIO())
        return archive

    def test_tag_and_both_binaries_must_agree(self):
        with tempfile.TemporaryDirectory() as root:
            archive = self.archive(Path(root))
            checker.verify(archive, "v0.7.1")
            for tag in ("v0.7.2", "v0.7.1;echo secret", "v00.7.1", "0.7.1"):
                with self.subTest(tag=tag), self.assertRaises(ValueError): checker.verify(archive, tag)
            # A mismatched proxy alone is rejected, even with a matching operator CLI.
            archive = self.archive(Path(root), proxy_version="0.3.0")
            with self.assertRaises(ValueError): checker.verify(archive, "v0.7.1")

    def test_archive_entries_are_restricted_before_execution(self):
        with tempfile.TemporaryDirectory() as root:
            for kwargs in ({"extra":True}, {"symlink":True}):
                archive = self.archive(Path(root), **kwargs)
                with self.subTest(kwargs=kwargs), self.assertRaises(ValueError): checker.verify(archive, "v0.7.1")

    def test_bump_wires_binary_check_and_both_formula_version_assertions(self):
        workflow = (ROOT / ".github/workflows/update-sandhi.yml").read_text()
        self.assertIn('python3 scripts/check-sandhi-archive.py linux.tgz "$TAG"', workflow)
        self.assertIn('shell_output("#{bin}/sandhi-proxy --version")', workflow)
        self.assertLess(workflow.index('scripts/check-sandhi-archive.py'), workflow.index('Rewrite the formula'))
