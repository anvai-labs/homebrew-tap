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


if __name__ == "__main__":
    unittest.main()
