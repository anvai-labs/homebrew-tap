import importlib.util
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("wheels", ROOT / "tools/gen-victor-resources.py")
wheels = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(wheels)


class VictorResourceTests(unittest.TestCase):
    def test_stable_abi_wheels_cannot_require_a_newer_python(self):
        self.assertIsNone(wheels.classify("example-1.0-cp313-abi3-macosx_11_0_arm64.whl"))
        self.assertEqual(wheels.classify("example-1.0-cp311-abi3-macosx_11_0_arm64.whl"), ({"mac_arm"}, 1))
        self.assertEqual(wheels.classify("example-1.0-cp312-cp312-manylinux_2_17_x86_64.whl"), ({"linux_x64"}, 0))
        self.assertEqual(wheels.classify("example-1.0-py3-none-any.whl"), ({"pure"}, 2))

    def test_assembly_preserves_formula_header_and_install(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "Formula").mkdir()
            formula = root / "Formula/victor.rb"
            header = 'class Victor < Formula\n  url "https://example.com/victor_ai-1.0.0.tar.gz"\n  preserve_rpath\n'
            install = '  def install\n    install_release\n  end\nend\n'
            formula.write_text(header + '\n  resource "old" do\n  end\n\n' + install)
            resources = root / "resources.rb"
            resources.write_text('resource "new" do\n  url "https://example.com/new.whl"\nend\n')
            subprocess.run([sys.executable, str(ROOT / "tools/assemble-victor-formula.py"), str(resources)],
                           cwd=root, check=True, capture_output=True)
            actual = formula.read_text()
            self.assertTrue(actual.startswith(header))
            self.assertTrue(actual.endswith(install))
            self.assertIn('\n  resource "new" do\n    url ', actual)
            self.assertNotIn('resource "old"', actual)
