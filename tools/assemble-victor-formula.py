#!/usr/bin/env python3
"""Splice freshly generated resource blocks into Formula/victor.rb.

Everything between the `preserve_rpath` stanza and `def install` is replaced
with the generated resource region, so the formula header, install and test
blocks are never touched by regeneration.

    python3 tools/gen-victor-resources.py --report /tmp/victor-resolve.json \
        --manifest tools/victor-resources.json > /tmp/victor-resources.rb
    python3 tools/assemble-victor-formula.py /tmp/victor-resources.rb
    brew style --fix Formula/victor.rb
"""

import pathlib
import sys


def main() -> int:
    resources = pathlib.Path(sys.argv[1]).read_text().rstrip() + "\n"
    path = pathlib.Path("Formula/victor.rb")
    lines = path.read_text().splitlines()
    anchor = next(i for i, line in enumerate(lines) if line == "  preserve_rpath")
    install = next(i for i, line in enumerate(lines) if line == "  def install")
    rebuilt = lines[: anchor + 1] + ["", ""] + resources.splitlines() + [""] + lines[install:]
    path.write_text("\n".join(rebuilt) + "\n")
    print(f"spliced resources between lines {anchor + 1} and {install + 1}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
