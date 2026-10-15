import importlib.util
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("sync", ROOT / "scripts/sync-upstream-releases.py")
sync = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(sync)


class UpstreamReleaseTests(unittest.TestCase):
    def test_semantic_comparison_and_no_downgrade(self):
        self.assertTrue(sync.needs_update(["v0.9.0"], "v0.14.0"))
        self.assertFalse(sync.needs_update(["v0.14.0"], "0.14.0"))
        with self.assertRaises(ValueError):
            sync.needs_update(["v0.14.0"], "v0.9.0")
        for value in ("v0.14.0-rc1", "v00.14.0", "v0.14.0\n", "v0.14.0;exit 1"):
            with self.subTest(value=value), self.assertRaises(ValueError):
                sync.version(value)

    def test_public_stable_release_and_non_yanked_sdist_required(self):
        for key in ("draft", "prerelease"):
            metadata = {"tag_name": "v1.0.0", "draft": False, "prerelease": False, key: True}
            with self.assertRaises(ValueError):
                sync.release_version("sandhi", metadata)
        with self.assertRaises(ValueError):
            sync.release_version("victor", {"info": {"version": "0.12.0"},
                "urls": [{"packagetype": "sdist", "yanked": True}]})

    def test_cask_drift_is_detected_and_never_downgraded(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "Formula").mkdir()
            (root / "Casks").mkdir()
            (root / "Formula/sentinelpass.rb").write_text('url "https://example.com/releases/download/v0.17.0/app"')
            (root / "Casks/sentinelpass.rb").write_text('  version "0.16.0"')
            current = sync.current_versions("sentinelpass", root)
            self.assertTrue(sync.needs_update(current, "v0.17.0"))
            with self.assertRaises(ValueError):
                sync.needs_update(current, "v0.16.0")

    def test_all_shipped_products_are_audited(self):
        self.assertEqual(set(sync.PRODUCTS), {path.stem for path in (ROOT / "Formula").glob("*.rb")})
        self.assertEqual({path.stem for path in (ROOT / "Casks").glob("*.rb")}, {"sentinelpass"})
        for product in sync.PRODUCTS:
            self.assertTrue(sync.current_versions(product))

    def test_dispatch_uses_existing_updater_and_explicit_version(self):
        self.assertIn("update-formula.yml", sync.dispatch_command("victor", "0.13.0"))
        self.assertEqual(sync.dispatch_command("victor", "0.13.0")[-1], "version=0.13.0")
        self.assertIn("update-sentinelpass.yml", sync.dispatch_command("sentinelpass", "v0.18.0"))
        self.assertEqual(sync.dispatch_command("sentinelpass", "v0.18.0")[-1], "tag=v0.18.0")
