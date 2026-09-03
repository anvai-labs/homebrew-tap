# CLAUDE.md

Homebrew tap for Anvai Labs products. Formulas install prebuilt release artifacts; see README for the formula table and audit.

# Branching & Releases

This tap is **trunk-only**: `main` is the only branch and every commit on it is releasable state. Formula bumps land via the automation PRs (update-*.yml, CI-gated) or direct verified pushes; upstream releases trigger bump PRs. There is no develop stage - a tap has no runtime to stabilize.

# Conventions

- Formula SHAs are always computed from actually downloaded release assets, never copied from memory.
- Every formula change is verified by a real `brew install`/`upgrade` plus binary run before it lands.
- The README audit table updates in the same change that changes any formula verdict.