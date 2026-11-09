"""Release-contract tests for the agentbrowser service-env override (ADR-034).

The generated agentbrowser-server wrapper must read the operator override
file ~/.config/agentbrowser/service.env at every SERVICE START (not at
install), refuse group/world-readable copies, and parse simple KEY=VALUE
lines without shell sourcing — so operators never hand-edit generated plists.
"""

import re
import unittest
from pathlib import Path

FORMULA = Path(__file__).parents[1] / "Formula" / "agentbrowser.rb"


def wrapper_section() -> str:
    """The generated wrapper script body (the `agentbrowser-server` heredoc)."""
    text = FORMULA.read_text(encoding="utf-8")
    match = re.search(r'\(bin/"agentbrowser-server"\)\.write <<~EOS\n(.*?)\n\s*EOS', text, re.DOTALL)
    if not match:
        raise AssertionError("agentbrowser-server wrapper heredoc missing")
    return match.group(1)


def caveats_section() -> str:
    text = FORMULA.read_text(encoding="utf-8")
    match = re.search(r"def caveats\n\s*<<~EOS\n(.*?)\n\s*EOS\n\s*end", text, re.DOTALL)
    if not match:
        raise AssertionError("caveats heredoc missing")
    return match.group(1)


class AgentbrowserServiceEnvTests(unittest.TestCase):
    def test_wrapper_reads_the_override_file_at_start(self):
        wrapper = wrapper_section()
        self.assertIn(".config/agentbrowser/service.env", wrapper)
        # Read per start: the file check sits in the runtime wrapper, before
        # the exec, and is NOT part of install-time Ruby.
        self.assertLess(wrapper.index("SERVICE_ENV_FILE"), wrapper.index("exec "))

    def test_requires_owner_only_permissions_and_refuses_loudly(self):
        wrapper = wrapper_section()
        self.assertIn('stat -c', wrapper)  # Linux (GNU) mode probe...
        self.assertIn("stat -f", wrapper)  # ...with the macOS (BSD) fallback
        self.assertIn('"600"', wrapper)
        self.assertIn('"400"', wrapper)
        self.assertIn("REFUSING", wrapper)
        self.assertIn("chmod 600", wrapper)

    def test_parses_key_value_lines_without_shell_sourcing(self):
        wrapper = wrapper_section()
        # The override file is parsed line-by-line, never sourced.
        self.assertNotIn('. "$SERVICE_ENV_FILE"', wrapper)
        self.assertIn("while IFS= read -r line", wrapper)
        self.assertIn('case "$line" in ""|"#"*)', wrapper)
        self.assertIn("[0-9]*", wrapper)  # non-shell-name keys are skipped

    def test_fail_open_when_absent_and_env_file_still_applied_last(self):
        wrapper = wrapper_section()
        self.assertIn('if [ -f "$SERVICE_ENV_FILE" ]', wrapper)
        self.assertLess(
            wrapper.index("SERVICE_ENV_FILE"),
            wrapper.index('ENV_FILE="#{etc}/agentbrowser/env"'),
            "the etc/agentbrowser/env shell fragment must stay the last-applied, winning layer",
        )

    def test_caveats_document_override_file_perms_and_restart_persistence(self):
        caveats = caveats_section()
        self.assertIn("~/.config/agentbrowser/service.env", caveats)
        self.assertIn("KEY=VALUE", caveats)
        self.assertIn("chmod 600", caveats)
        self.assertIn("brew services restart", caveats)
        self.assertIn("survive plist regeneration", caveats)

    def test_formula_revision_bumped_for_wrapper_change(self):
        text = FORMULA.read_text(encoding="utf-8")
        match = re.search(r'^\s*revision\s+(\d+)', text, re.MULTILINE)
        self.assertIsNotNone(match, "formula-only wrapper change requires a revision bump")
        self.assertGreaterEqual(int(match.group(1)), 3)


if __name__ == "__main__":
    unittest.main()
