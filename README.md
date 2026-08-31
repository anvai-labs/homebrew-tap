# Homebrew Tap — Anvai Labs

One tap for every Anvai Labs product with an installable binary. Formulas
install the **prebuilt release artifacts** published by each repository's
release workflow, selecting the correct archive for your platform.

## Install

```bash
brew tap anvai-labs/tap https://github.com/anvai-labs/homebrew-tap
brew install anvai-labs/tap/sandhi
brew install anvai-labs/tap/sentinelpass
brew install anvai-labs/tap/victor
```

(`brew tap anvai-labs/tap` resolves to this repository automatically; the full
URL is spelled out so the source is never ambiguous.)

## Formulas

| Formula | Installs | Platforms | Upstream |
|---|---|---|---|
| `sandhi` | `sandhi-proxy` (AI usage gateway server; the `sandhi` operator CLI joins from v0.2.1) | macOS arm64, Linux x86_64 | [anvai-labs/sandhi](https://github.com/anvai-labs/sandhi) |
| `sentinelpass` | `sentinelpass` + `sentinelpass-host` + `sentinelpass-ui` (+ `-daemon` on Linux) | macOS arm64, Linux x86_64 | [anvai-labs/sentinelpass](https://github.com/anvai-labs/sentinelpass) |
| `victor` | `victor` (AI coding assistant; PyPI virtualenv) | macOS + Linux | [anvai-labs/victor](https://github.com/anvai-labs/victor) |

### Running sandhi as a service

```bash
brew services start anvai-labs/tap/sandhi
```

The service listens on `127.0.0.1:8787` and stores usage in
`$(brew --prefix)/var/sandhi/usage.db`; override by writing a launchd override
or running the binary yourself with the `SANDHI_*` environment (see
`brew services info anvai-labs/tap/sandhi` and the
[sandhi operator docs](https://github.com/anvai-labs/sandhi/blob/main/docs/operator/proxy-guide.adoc)).

### Not here (yet), and why — full audit 2026-08-31

Every non-fork repository across `anvai-labs`, `anvaiops`, and `vjsingh1984`
was audited for formula-worthiness (releases with installable binaries,
public reachability, macOS+Linux coverage):

| Repo | Verdict | Reason |
|---|---|---|
| proximaDB | skip | database server, no macOS build; its deb/rpm/msi cover Linux/Windows. **Decision 2026-08-31: stays skipped** (standing default; revisit only if macOS builds get funded upstream) |
| agentbrowser (anvaiops) | **pending visibility** | excellent multi-platform binaries (`darwin-arm64/x64`, `linux-arm64/x64`, windows, latest v1.4.0) — but the repo is PRIVATE, so a public tap cannot download its release assets. Flips to formulable the day the repo or its releases go public. **Owner visibility decision still open as of 2026-08-31** |
| ibkrtrading (anvaiops) | skip | private + no releases |
| inferflux | skip | public, but no releases published (rechecked 2026-08-31: still zero) — formulable once a release ships target-suffixed archives + sha256sums.txt |
| victor verticals / registry / firmus / interviewer / stock-market-prediction / anvaiops | skip | Python libraries and services; `pipx`/`uv` remain the right installers |
| reasoning-engine / LLM-Inference-Service | skip | frameworks/services, not installable CLIs |
| legacy Java/Hadoop repos | skip | sample code, not products |

## Note on the old tap

`vjsingh1984/homebrew-tap` predates this one and carries a mirror of
`victor.rb`. It is frozen; install from `anvai-labs/tap` (this repository).

## For maintainers: bumping a formula on release

`sandhi`: run **Actions → Update Sandhi Formula** in this repository with the
new tag (e.g. `v0.2.1`) — it downloads the release assets, recomputes the
SHA-256s, and commits the formula update.

`sentinelpass`: edit `Formula/sentinelpass.rb` (`version` + the two `sha256`
lines; the sums are also published in each release's `sha256sums.txt`). The
exact procedure — run it from a scratch clone of this tap:

```bash
V=<new version>   # e.g. V=0.8.0
curl -fsSL -o /tmp/sp-macos.tgz "https://github.com/anvai-labs/sentinelpass/releases/download/v${V}/sentinelpass-${V}-macos.tar.gz"
curl -fsSL -o /tmp/sp-linux.tgz "https://github.com/anvai-labs/sentinelpass/releases/download/v${V}/sentinelpass-${V}-linux.tar.gz"
shasum -a 256 /tmp/sp-macos.tgz /tmp/sp-linux.tgz
curl -fsSL "https://github.com/anvai-labs/sentinelpass/releases/download/v${V}/sha256sums.txt"   # cross-check both sums
```

then replace `v${V}` in both URLs (the tag path and the tarball names) and set
the two `sha256` lines (macOS sum first). Nothing else changes — brew detects
the version from the URLs. The upstream automation
(`anvai-labs/sentinelpass` release.yml → "Bump Homebrew formula" job, backed
by `scripts/bump-homebrew-formula.sh`) performs exactly this bump, but skips
until the `TAP_TOKEN` secret (fine-grained PAT with Contents:write on this
repo) is configured on that repository; asset names are arch-unnamed
(`-macos.tar.gz` is arm64-only), so until upstream renames them per-arch the
formula cannot cover more platforms than these two tarballs.

`victor`: automatic — `update-formula.yml` polls PyPI every 6 hours (it rewrites only the
sdist `url`/`sha256`). victor-ai itself is installed from that sdist; its dependency closure
ships as pinned wheel resources. After a major bump that changes dependency constraints,
regenerate them: `tools/gen-victor-resources.py` (see its header) + `tools/assemble-victor-formula.py`,
then `brew style --fix Formula/victor.rb` and re-run `brew install && brew test`.

## Validation

CI runs on every push to `main` (and every PR): syntax + release-contract
checks, then `brew audit` on all three formulas followed by a real
`brew install` and `brew test` of each, against the checked-out tap on a Linux
runner. The required `CI Success` status check on `main` blocks merges when it
goes red.

## Adding a new product

1. Ship target-suffixed archives plus a `sha256sums.txt` in the product's
   GitHub releases — at minimum `aarch64-apple-darwin` and
   `x86_64-unknown-linux-gnu`.
2. Add `Formula/<name>.rb`: one url/sha256 pair per platform, versions
   **literal** (brew detects them from the URLs), a `livecheck` block pointing
   at the releases page, and a `test` block that actually runs the binary.
3. Add a bump workflow (`.github/workflows/update-<name>.yml`, mirroring
   `update-sandhi.yml`) or document the manual runbook above.
4. Update the formula table and the audit table in this README in the same
   change.

CI audits, installs and tests the formula on the push.

## Note on the old tap URL

Instructions older than 2026-08 may say `brew tap vjsingh1984/tap`. That
repository was transferred to the `anvai-labs` org, and GitHub redirects the
old URL here permanently — old instructions keep working, and
`anvai-labs/tap` is the single authoritative source.
