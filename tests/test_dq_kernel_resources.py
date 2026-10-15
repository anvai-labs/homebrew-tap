import importlib.util
import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("dq_update", ROOT / "scripts/update-dq-kernel.py")
update = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(update)


class DqKernelResources(unittest.TestCase):
    def test_native_wheels_must_cover_both_supported_platforms(self):
        mac = {"filename": "sample-1.0-cp312-cp312-macosx_14_0_arm64.whl"}
        linux = {"filename": "sample-1.0-cp312-cp312-manylinux_2_28_x86_64.whl"}
        with self.assertRaises(ValueError):
            update.choose_wheels([mac])
        self.assertEqual(update.choose_wheels([mac, linux]), {"mac": mac, "linux": linux})

    def test_newer_python_or_platform_cannot_satisfy_resources(self):
        for filename in ("sample-1.0-cp313-abi3-macosx_14_0_arm64.whl",
                         "sample-1.0-cp312-cp312-macosx_15_0_arm64.whl",
                         "sample-1.0-cp312-cp312-manylinux_2_40_x86_64.whl"):
            with self.subTest(filename=filename), self.assertRaises(ValueError):
                update.choose_wheels([{"filename": filename}])

    def test_manifest_pins_backends_and_all_formula_resources(self):
        manifest = json.loads((ROOT / "tools/dq-kernel-resources.json").read_text())
        formula = (ROOT / "Formula/dq-kernel.rb").read_text()
        names = set(manifest["resources"])
        self.assertTrue({"pyspark", "pydeequ", "setuptools", "wheel", "poetry-core", "packaging"} <= names)
        for name, resource in manifest["resources"].items():
            self.assertIn(f'resource "{name}" do', formula)
            self.assertTrue("pure" in resource or "source" in resource or {"mac", "linux"} <= resource.keys())
            for platform, entry in resource.items():
                if platform == "version":
                    continue
                self.assertIn(entry["url"], formula)
                self.assertIn(entry["sha256"], formula)
