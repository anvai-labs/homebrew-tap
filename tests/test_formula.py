import hashlib
import json
import re
import unittest
import urllib.request
from pathlib import Path


FORMULA = Path(__file__).parents[1] / "Formula" / "victor.rb"
PYPI_JSON = "https://pypi.org/pypi/victor-ai/json"


def formula_field(name: str) -> str:
    match = re.search(rf'^\s*{name}\s+"([^"]+)"', FORMULA.read_text(encoding="utf-8"), re.MULTILINE)
    if not match:
        raise AssertionError(f"formula field missing: {name}")
    return match.group(1)


class VictorFormulaTests(unittest.TestCase):
    def test_formula_identity_uses_organization_repository(self):
        self.assertEqual(formula_field("homepage"), "https://github.com/anvai-labs/victor")

    def test_formula_uses_latest_pypi_sdist_and_digest(self):
        with urllib.request.urlopen(PYPI_JSON, timeout=20) as response:
            metadata = json.load(response)

        version = metadata["info"]["version"]
        sdist = next(item for item in metadata["urls"] if item["packagetype"] == "sdist")
        self.assertIn(f"victor_ai-{version}.tar.gz", formula_field("url"))
        self.assertEqual(formula_field("url"), sdist["url"])
        self.assertEqual(formula_field("sha256"), sdist["digests"]["sha256"])

    def test_formula_digest_matches_downloaded_archive(self):
        with urllib.request.urlopen(formula_field("url"), timeout=30) as response:
            digest = hashlib.sha256(response.read()).hexdigest()
        self.assertEqual(digest, formula_field("sha256"))

    def test_formula_vendors_pep517_build_requirements(self):
        text = FORMULA.read_text(encoding="utf-8")

        self.assertRegex(text, re.compile(r'^\s*resource "setuptools" do$', re.MULTILINE))
        self.assertRegex(text, re.compile(r'^\s*resource "wheel" do$', re.MULTILINE))
        self.assertIn("setuptools-", text)
        self.assertIn("wheel-", text)

    def test_only_the_head_url_is_the_victor_sdist(self):
        urls = re.findall(r'^\s*url\s+"([^"]+)"', FORMULA.read_text(encoding="utf-8"), re.MULTILINE)
        sdists = [url for url in urls if "/victor_ai-" in url]
        self.assertEqual(sdists, [urls[0]], "a resource url was rewritten to the victor-ai sdist")

    def test_closure_matches_victor_exact_pins(self):
        version = re.search(r"victor_ai-([^/]+)\.tar\.gz", formula_field("url")).group(1)
        with urllib.request.urlopen(f"https://pypi.org/pypi/victor-ai/{version}/json", timeout=20) as response:
            requires = json.load(response)["info"]["requires_dist"] or []
        text = FORMULA.read_text(encoding="utf-8")
        pins = []
        for req in requires:
            if "extra ==" in req:
                continue
            match = re.match(r"^([A-Za-z0-9_.-]+)\s*==\s*([^;,\s]+)", req)
            if match:
                pins.append((re.sub(r"[-_.]+", "_", match.group(1)).lower(), match.group(2)))
        self.assertTrue(pins, "victor-ai declares no exact pins; test is vacuous")
        for name, pinned in pins:
            found = re.findall(rf"/{name}-([^-/]+)-", text, re.IGNORECASE)
            self.assertTrue(found, f"{name}=={pinned} has no vendored resource")
            self.assertEqual(set(found), {pinned}, f"{name} vendored {sorted(set(found))}, victor pins {pinned}")

    def test_formula_installs_victor_sdist_without_build_isolation(self):
        text = FORMULA.read_text(encoding="utf-8")

        self.assertIn("venv.pip_install T.must(buildpath), build_isolation: false", text)


if __name__ == "__main__":
    unittest.main()
