# Homebrew Tap — Anvai Labs

One tap for every Anvai Labs product with an installable binary. Formulas
install the **prebuilt release artifacts** published by each repository's
release workflow, selecting the correct archive for your platform.

## Install

```bash
brew tap anvai-labs/tap https://github.com/anvai-labs/homebrew-tap
brew install anvai-labs/tap/sandhi
brew install anvai-labs/tap/sentinelpass
brew install --cask anvai-labs/tap/sentinelpass   # desktop app — see Casks below
brew install anvai-labs/tap/victor
brew install anvai-labs/tap/agentbrowser
brew install anvai-labs/tap/inferflux
```

(`brew tap anvai-labs/tap` resolves to this repository automatically; the full
URL is spelled out so the source is never ambiguous.)

## Formulas

| Formula | Installs | Platforms | Upstream |
|---|---|---|---|
| `sandhi` | `sandhi-proxy` (AI usage gateway server) + `sandhi` (operator CLI) | macOS arm64, Linux x86_64 | [anvai-labs/sandhi](https://github.com/anvai-labs/sandhi) |
| `sentinelpass` | `sentinelpass` + `sentinelpass-host` + `sentinelpass-ui` (+ `-daemon` on Linux) | macOS arm64, Linux x86_64 | [anvai-labs/sentinelpass](https://github.com/anvai-labs/sentinelpass) |
| `victor` | `victor` (AI coding assistant; PyPI virtualenv) | macOS arm64, Linux x86_64 | [anvai-labs/victor](https://github.com/anvai-labs/victor) |
| `agentbrowser` | `agentbrowser`, `agentbrowser-server`, `agentbrowser-mcp` (agent-native browser service: CLI, service daemon, MCP server) | macOS arm64, macOS x64, Linux x86_64, Linux arm64 | [anvai-labs/agentbrowser](https://github.com/anvai-labs/agentbrowser) |
| `inferflux` | `inferfluxd` (C++ LLM inference server) + `inferctl` (operator CLI) | macOS arm64, Linux x86_64, Linux arm64 | [anvai-labs/inferflux](https://github.com/anvai-labs/inferflux) |

InferFlux's formula follows v0.5.0. The standard Linux release archives are
CPU-only; keep a separately accepted CUDA/ROCm deployment on its source-qualified
GPU build. Installing this formula does not upgrade or validate that serving
runtime. See the [release acceptance and deployment limits](https://github.com/anvai-labs/inferflux/blob/develop/docs/releases/v0.5.0.md).

## Casks

| Cask | Installs | Platforms | Upstream |
|---|---|---|---|
| `sentinelpass` | `SentinelPass.app` (desktop app; self-contained — embeds its own daemon and browser native-messaging host, manages the daemon lifecycle itself) | macOS arm64 | [anvai-labs/sentinelpass](https://github.com/anvai-labs/sentinelpass) |

Formula and cask may share a token (docker precedent): bare `brew install
sentinelpass` installs the CLI formula, `brew install --cask sentinelpass`
installs the desktop app. Keep both channels on the same release — whichever
UI launched last re-points the browser native-messaging manifests at its own
host copy. The app is ad-hoc signed until upstream notarizes (sentinelpass
issue #148), so the first launch may show a Gatekeeper "damaged" warning; the
cask never touches the vault in `~/Library/Application Support/PasswordManager`.

### Running sandhi as a service

Sandhi defaults to OIDC SSO. Before starting the service, create a private
`$(brew --prefix)/etc/sandhi/oidc.json` using the
[OIDC setup guide](https://github.com/anvai-labs/sandhi/blob/main/docs/operator/oidc-sso.md).
Missing configuration or failed identity-provider discovery prevents startup.
The upgrade does not copy credentials or migrate an existing gateway's database.

```bash
brew services start anvai-labs/tap/sandhi
```

The service listens on `127.0.0.1:8787` and stores usage in
`$(brew --prefix)/var/sandhi/usage.db`; override by writing a launchd override
or running the binary yourself with the `SANDHI_*` environment (see
`brew services info anvai-labs/tap/sandhi` and the
[sandhi operator docs](https://github.com/anvai-labs/sandhi/blob/main/docs/operator/proxy-guide.adoc)).
For an intentionally retained token deployment, run the binary with an explicit
`SANDHI_AUTH_MODE=tokens` and its existing private configuration. OIDC failure
never selects this mode automatically.

### Additional product candidates — public repository audit 2026-10-15

Reviewed the public `anvai-labs` repositories' releases, README files, and
package manifests. The five live products are listed above. This table records
packaging candidates, not validated new installs; private repository findings
are kept outside this public tap.

| Repo | Verdict | Reason / next step |
|---|---|---|
| [dq-kernel](https://github.com/anvai-labs/dq-kernel/releases/tag/v0.1.0) | **next formula candidate** | v0.1.0 ships a wheel and sdist with `dq-kernel` and `dq-validate` entry points. Package a Python 3.12 virtualenv, pin the dependency closure, and test a real quality check. The Spark runner needs the supported Spark 3.5.9 runtime and Java 17; a help-only test is insufficient. |
| [victor-invest](https://github.com/anvai-labs/victor-invest) | conditional formula + bundle | Has `victor-invest` and `investigator` CLIs, but the GitHub v1.0.0 release has no attached packages and the default-branch manifest says 0.7.0. Reconcile release metadata and validate the Victor dependency closure first. An optional Brewfile can provision PostgreSQL and Ollama alongside the eventual formula. |
| [proximaDB](https://github.com/anvai-labs/proximaDB/releases/tag/v0.4.0) | skip under standing decision | v0.4.0 has a Linux x86_64 tarball and Windows packages, but no macOS release. A Linux-only formula is technically possible. **Decision 2026-08-31 remains: revisit only if macOS builds get funded upstream.** |
| Investigator | defer | No packaged release or install manifest; overlaps the newer `victor-invest` product. Consolidate the distribution first. |
| firmus | defer | No release or package manifest; upstream explicitly labels it a research prototype. Establish a supported release and CLI contract before packaging. |
| LLM-Inference-Service / reasoning-engine | dependency bundles only for now | Source-run services/training code with no published installable release. A Brewfile could provision development prerequisites; GPU stacks and model downloads still need their own setup. |
| victor-registry | no separate formula | Registry metadata consumed through Victor's existing vertical commands. |
| data-quality-framework | skip | Archived predecessor; prefer the active `dq-kernel`. |
| impala-ldap-ssl-jdbc / KerberizedHDFSAccess / JCopyClientServer / SecureHadoopCode / kafkaSparkStreamingHbase | skip | Samples or scaffolding, without a supported product release. |
| homebrew-tap / winget-pkgs | no additional package | Distribution infrastructure; `winget-pkgs` is a fork. |

No additional public desktop-app release was found that warrants a new cask.
For existing products, a separate AI-workstation Brewfile could group Victor,
Sandhi, agentbrowser, and optional InferFlux. A Brewfile installs selected
packages; it does not configure credentials, models, or running services.

## Note on the old tap

`vjsingh1984/homebrew-tap` predates this one and was **transferred into the
`anvai-labs` org** — it is this repository, not a second tap (see the URL note
below). Install from `anvai-labs/tap`.

## For maintainers: bumping a formula on release

`sandhi`: run **Actions → Update Sandhi Formula** in this repository with the
new tag (e.g. `v0.14.0`) — it downloads the release assets, recomputes the
SHA-256s, and commits the formula update.

`sentinelpass`: run **Actions → Update SentinelPass Formula** in this
repository with the new tag (e.g. `v0.9.0`) — same flow as sandhi: it
downloads the release assets, recomputes the SHA-256s, and opens the bump PR
with a changed-file guard. The bot bumps **both** `Formula/sentinelpass.rb`
and `Casks/sentinelpass.rb` in one PR, downloads everything into `RUNNER_TEMP`,
and cross-checks all three assets against the release's `sha256sums.txt`. A
missing DMG or checksum mismatch stops the entire bump so the two channels
cannot drift apart. The manual procedure, if you
ever need to do it by hand — run it from a scratch clone of this tap:

```bash
V=<new version>   # e.g. V=0.8.0
curl -fsSL -o /tmp/sp-macos.tgz "https://github.com/anvai-labs/sentinelpass/releases/download/v${V}/sentinelpass-${V}-macos.tar.gz"
curl -fsSL -o /tmp/sp-linux.tgz "https://github.com/anvai-labs/sentinelpass/releases/download/v${V}/sentinelpass-${V}-linux.tar.gz"
curl -fsSL -o /tmp/sp.dmg      "https://github.com/anvai-labs/sentinelpass/releases/download/v${V}/sentinelpass-${V}-macos.dmg"
shasum -a 256 /tmp/sp-macos.tgz /tmp/sp-linux.tgz /tmp/sp.dmg
curl -fsSL "https://github.com/anvai-labs/sentinelpass/releases/download/v${V}/sha256sums.txt"   # cross-check all three sums
```

then in the formula replace `v${V}` in both URLs (the tag path and the tarball
names) and set the two `sha256` lines (macOS sum first); in the cask rewrite
only the `version` stanza and the `sha256 arm:` line — the cask URL is fully
version-templated, and cask audit requires it to stay that way (a literal URL
is treated as unversioned). Nothing else changes. Keep the commands above:
they double as the diff-shape check (they reproduce the bot's exact change).
Asset names are arch-unnamed (`-macos.tar.gz` and `-macos.dmg` are arm64-only),
so until upstream renames them per-arch the formula and cask cannot cover more
platforms than these.

Upstream's own release.yml "Bump Homebrew formula" job is retired for this
purpose: it pushed the bump directly to `main`, which checks-only branch
protection rejects (GH006, required "CI Success" — direct pushes can never
satisfy it), so it has failed on every release since v0.9.0. Bumps come from
this repository instead.

`victor`: the release checker polls PyPI and dispatches `update-formula.yml`
with the newer stable version. The updater downloads and hashes the sdist,
resolves that release's dependency constraints on Python 3.12, and regenerates
`Formula/victor.rb` wheel resources and `tools/victor-resources.json` together.
It verifies an offline install and `pip check` before opening the PR. Missing
wheels for macOS arm64 or Linux x86_64 stop the bump. A newer Victor release's
Sandhi pin is taken from its published requirements, not inferred from the
standalone Sandhi formula version. Manual regeneration still uses
`tools/gen-victor-resources.py` and `tools/assemble-victor-formula.py`.

`inferflux`: run **Actions → Update Inferflux Formula** in this repository with the new tag
(e.g. `v0.1.1`) — same shape as the sandhi bot: it downloads the Darwin-arm64,
Linux-x86_64, and Linux-aarch64 cpack tgz archives, recomputes the SHA-256s from the actual bytes, and commits
the formula update. Cross-check the three sums against the release's `sha256sums.txt`.

**Automatic release discovery:** `sync-upstream-releases.yml` checks all five
products every six hours and can also be dispatched manually. GitHub products
follow their latest public stable release; Victor follows PyPI. SentinelPass's
formula and cask are checked together. Downgrades and prereleases are refused.
The checker dispatches the existing product updater only when a newer version
or cask drift is found; it never merges or upgrades an installed service.
Run `python3 scripts/sync-upstream-releases.py` for a read-only version audit.

**Bot PR validation:** every updater explicitly dispatches `ci.yml` on its
updated automation branch after creating or updating a PR. This uses the
job token's supported `workflow_dispatch` event, avoiding manual empty commits
or close/reopen steps. CI still tests the actual candidate commit, and required
`CI Success` branch protection still gates merging. No automatic merge is enabled.

**Coordinated release hold (2026-10-15):** Sandhi 0.14.0 is published and the
agentbrowser 1.18.0 bump is prepared in draft PR #104. Keep that PR unmerged
until the new Victor release pinned to Sandhi 0.14 is published, its dependency
resources are regenerated, and the final combined PR passes CI. Victor 0.12.0
is currently the latest published release; its existing 0.11.0 Sandhi binding
override and stale 0.9.0 `victor-contracts` resource must be reconciled with the
new release. An unchanged top-level Victor version is not evidence that its
vendored dependencies are aligned.

## Validation

CI runs on every push to `main` (and every PR): syntax + release-contract
checks, then `brew audit` on every formula followed by a real
`brew install` and `brew test` of each, against the checked-out tap on a Linux
runner. Casks get the same treatment on a macOS runner: `brew audit --cask`
plus a real `brew install --cask` and an install smoke (bundle identity,
embedded sidecars, quarantine, Gatekeeper status) — no `brew test`, which
does not exist for casks. The required `CI Success` status check on `main`
blocks merges when any of those jobs go red.

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
5. If the product also ships a macOS `.app`, add `Casks/<name>.rb` (app
   stanza, arm/intel sha256, livecheck, vault-safe uninstall/zap, caveats)
   and extend the CI `casks` job + the bump bot's `add-paths` with it.

CI audits, installs and tests the formula on the push.

## Note on the old tap URL

Instructions older than 2026-08 may say `brew tap vjsingh1984/tap`. That
repository was transferred to the `anvai-labs` org, and GitHub redirects the
old URL here permanently — old instructions keep working, and
`anvai-labs/tap` is the single authoritative source.
