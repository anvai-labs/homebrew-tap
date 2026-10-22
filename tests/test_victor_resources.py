"""Closure-drift gate for the victor formula.

The update workflow rewrites only the sdist url/sha256, so a victor-ai
release that moves its dependency constraints would otherwise produce a
formula whose vendored wheel closure no longer satisfies the sdist — a
stale bump that only fails later, at the real-install CI job. These tests
fail fast instead, at the unit-test stage both the updater workflow and
CI run, by comparing the pinned sdist's declared requirements against
tools/victor-resources.json.
"""

import json
import re
import tarfile
import unittest
import urllib.request
from pathlib import Path


FORMULA = Path(__file__).parents[1] / "Formula" / "victor.rb"
MANIFEST = Path(__file__).parents[1] / "tools" / "victor-resources.json"
PYPI_VERSION_JSON = "https://pypi.org/pypi/victor-ai/{version}/json"


def formula_field(name: str) -> str:
    match = re.search(rf'^\s*{name}\s+"([^"]+)"', FORMULA.read_text(encoding="utf-8"), re.MULTILINE)
    if not match:
        raise AssertionError(f"formula field missing: {name}")
    return match.group(1)


def normalize(name: str) -> str:
    return re.sub(r"[-_.]+", "-", name).lower()


def pinned_version() -> str:
    match = re.search(r"victor_ai-([0-9][0-9a-zA-Z.*]*)\.tar\.gz$", formula_field("url"))
    if not match:
        raise AssertionError(f"formula url does not pin a victor_ai sdist: {formula_field('url')}")
    return match.group(1)


def parse_requirement(requirement: str) -> tuple[str, str, list[tuple[str, str]]]:
    """Split a requires_dist entry into (name, marker, version specs)."""
    marker = ""
    if ";" in requirement:
        requirement, marker = requirement.split(";", 1)
    name = re.match(r"\s*([A-Za-z0-9._-]+)", requirement).group(1)
    specs = re.findall(r"(==|>=|<=|!=|~=|>|<)\s*([0-9][0-9A-Za-z.*-]*)", requirement)
    return name, marker, specs


def version_key(version: str) -> tuple[int, ...]:
    """Numeric release prefix of a version ('2.16.0rc1' -> (2, 16, 0))."""
    release = re.match(r"([0-9]+(?:\.[0-9]+)*)", version).group(1)
    return tuple(int(part) for part in release.split("."))


def satisfies(version: str, op: str, bound: str) -> bool:
    have, want = version_key(version), version_key(bound)
    if op == "==":
        prefix = want[:-1] if bound.endswith(".*") else want
        return have[: len(prefix)] == prefix
    if op == "!=":
        prefix = want[:-1] if bound.endswith(".*") else want
        return have[: len(prefix)] != prefix
    if op == ">=":
        return have >= want
    if op == "<=":
        return have <= want
    if op == ">":
        return have > want
    if op == "<":
        return have < want
    if op == "~=":  # >= bound and == prefix(bound minus last component).*
        return have >= want and have[: len(want) - 1] == want[: len(want) - 1]
    raise AssertionError(f"unsupported specifier operator: {op}")


def core_requirements() -> list[tuple[str, list[tuple[str, str]]]]:
    """Non-extra requirements declared by the pinned victor-ai sdist."""
    with urllib.request.urlopen(PYPI_VERSION_JSON.format(version=pinned_version()), timeout=20) as response:
        requires_dist = json.load(response)["info"]["requires_dist"] or []
    core = []
    for requirement in requires_dist:
        name, marker, specs = parse_requirement(requirement)
        if "extra ==" in marker or "extra !=" in marker:
            continue  # pulled in only under an extra: deliberately not vendored
        core.append((name, specs))
    return core


class VictorResourceClosureTests(unittest.TestCase):
    def setUp(self):
        manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
        self.versions = {
            normalize(name): entry["version"]
            for name, entry in manifest.items()
            if not name.startswith("_")
        }

    def test_manifest_covers_every_direct_runtime_dependency(self):
        missing = sorted(
            f"{name}{specs}"
            for name, specs in core_requirements()
            if normalize(name) not in self.versions
        )
        self.assertEqual(
            missing,
            [],
            "victor-ai {} declares runtime deps absent from tools/victor-resources.json; "
            "regenerate with tools/gen-victor-resources.py".format(pinned_version())
            + f" (missing: {missing})",
        )

    def test_manifest_pins_satisfy_direct_constraints(self):
        violations = []
        for name, specs in core_requirements():
            vendored = self.versions.get(normalize(name))
            if vendored is None:
                continue  # coverage failure, reported by the test above
            for op, bound in specs:
                if not satisfies(vendored, op, bound):
                    violations.append(f"{name}: vendored {vendored} violates {op}{bound}")
        self.assertEqual(
            violations,
            [],
            "vendored wheels no longer satisfy the pinned sdist's constraints; "
            "regenerate with tools/gen-victor-resources.py",
        )

    def test_manifest_covers_sdist_build_requirements(self):
        # pip installs the sdist with build isolation disabled, so its PEP 517
        # build requirements must be vendored as resources too.
        with urllib.request.urlopen(formula_field("url"), timeout=30) as response:
            sdist_path = Path("/tmp") / formula_field("url").rsplit("/", 1)[-1]
            sdist_path.write_bytes(response.read())
        with tarfile.open(sdist_path, "r:gz") as archive:
            pyproject = archive.extractfile(
                next(member for member in archive.getmembers() if member.name.endswith("pyproject.toml"))
            ).read().decode("utf-8")
        requires = re.search(r"requires\s*=\s*\[(.*?)\]", pyproject, re.DOTALL)
        build_requirements = requires.group(1) if requires else ""
        missing = sorted(
            set(
                normalize(parsed[0])
                for parsed in (parse_requirement(item) for item in re.findall(r'"([^"]+)"', build_requirements))
                if normalize(parsed[0]) not in self.versions
            )
        )
        self.assertEqual(missing, [], f"unvendored PEP 517 build requirements: {missing}")


if __name__ == "__main__":
    unittest.main()
