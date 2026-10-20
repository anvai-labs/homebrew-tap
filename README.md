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
brew install anvai-labs/tap/dq-kernel
brew install anvai-labs/tap/proximadb       # Linux x86_64 only
```

(`brew tap anvai-labs/tap` resolves to this repository automatically; the full
URL is spelled out so the source is never ambiguous.)

## Formulas

| Formula | Installs | Platforms | Upstream |
|---|---|---|---|
| `sandhi` | `sandhi-proxy` (AI usage gateway server) + `sandhi` (operator CLI) | macOS arm64, Linux x86_64 | [anvai-labs/sandhi](https://github.com/anvai-labs/sandhi) |
| `sentinelpass` | `sentinelpass` + `sentinelpass-host` + `sentinelpass-ui` (+ `-daemon` on Linux) | macOS arm64, Linux x86_64 | [anvai-labs/sentinelpass](https://github.com/anvai-labs/sentinelpass) |
| `victor` | `victor` (AI coding assistant; PyPI virtualenv) | macOS + Linux | [anvai-labs/victor](https://github.com/anvai-labs/victor) |
| `agentbrowser` | `agentbrowser`, `agentbrowser-server`, `agentbrowser-mcp` (agent-native browser service: CLI, service daemon, MCP server) | macOS arm64, macOS x64, Linux x86_64, Linux arm64 | [anvai-labs/agentbrowser](https://github.com/anvai-labs/agentbrowser) |
| `inferflux` | `inferfluxd` (C++ LLM inference server) + `inferctl` (operator CLI) | macOS arm64, Linux x86_64, Linux arm64 | [anvai-labs/inferflux](https://github.com/anvai-labs/inferflux) |
| `dq-kernel` | `dq-kernel` + `dq-validate`, with pinned Spark/PyDeequ dependencies | macOS 14+ arm64, Linux x86_64 | [anvai-labs/dq-kernel](https://github.com/anvai-labs/dq-kernel) |
| `proximadb` | `proximadb-server`, `proximadb-bench`, `proximadb-migrate` | Linux x86_64 | [anvai-labs/proximaDB](https://github.com/anvai-labs/proximaDB) |
InferFlux's formula follows v0.5.2 (since 2026-10-20; v0.5.1 was skipped in
the tap). The standard Linux release archives are CPU-only; keep a separately
accepted CUDA/ROCm deployment on its source-qualified GPU build. Installing
this formula does not upgrade or validate that serving runtime. See the
[release acceptance and deployment
limits](https://github.com/anvai-labs/inferflux/blob/develop/docs/releases/v0.5.2.md).

## Data tools

`dq-kernel` is a CLI/Python product, **not a localhost web UI**. It installs
`dq-kernel` (run checks) and `dq-validate` (validate HOCON rules). The formula
includes Spark 3.5.9, PyDeequ 1.7.0, Python 3.12, and Java 17. It does not
start a background service. Spark's own job monitor is not a dq-kernel UI.

```bash
dq-validate --format json /absolute/path/rules.conf
dq-kernel file:///absolute/path/rules.conf --spark-master 'local[2]' \
  --report-json report.json --dataset-id <immutable-dataset-id> \
  --dataset-sha256 <sha256-of-the-input-dataset>
```

The rules must reference datasets available to that Spark session/catalog.
Use a `file://` URI with `dq-kernel`; the released framework treats a bare
path as inline HOCON. A passing run returns 0; failed checks return 1. Reports
use `dq-report/v1` and include dataset and rule-set digests. Optional cloud
and Great Expectations integrations are not bundled. Deequ rules require the
matching upstream Deequ JVM artifact; the built-in custom checks tested by
this tap run without downloading a JVM extension.

`proximadb` installs the three public Linux binaries and example configuration
under `$(brew --prefix proximadb)/share/proximadb/config`. Copy and configure
an example before running `proximadb-server --config <path>`. Installation
starts no server and changes no existing database. The upstream v0.4.1 server
release has no macOS or Linux arm64 archive. The embedded Python engine is a
separate PyPI distribution (wheels since 0.4.1); `brew install proximadb`
does not provide `import proximadb_embedded`.

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

Sandhi 0.9.1 defaults to OIDC SSO. Before starting the service, create a private
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

### Not here (yet), and why — full audit 2026-08-31

Every non-fork repository across `anvai-labs`, `anvaiops`, and `vjsingh1984`
was audited for formula-worthiness (releases with installable binaries,
public reachability, macOS+Linux coverage):

| Repo | Verdict | Reason |
|---|---|---|
| proximaDB | **live, Linux x86_64** | Owner selected server packaging on 2026-10-15, superseding the earlier macOS-build hold. v0.4.1's published Linux archive is installed without a source build (0.4.0 → 0.4.1 bump verified against the release `SHA256SUMS.txt`); macOS remains unsupported. Since 2026-10-18 upstream's release workflow lands tap bumps itself via PR (see maintainers section); the tap's updater is the fallback. |
| dq-kernel | **live** | OSS v0.1.0 Python release with pinned Spark and PyDeequ resources. CI installs it and checks real passing/failing Spark checks and JSON reports on Linux and macOS. |
| ProximaDB embedded | wheels exist (0.4.1), formula pending | v0.4.1 publishes `cp311-abi3` wheels on PyPI (macOS arm64, Linux x86_64/aarch64, Windows) alongside the source archive; v0.4.0 had none. No embedded formula is published by this change. |
| agentbrowser | **live** (formula since 2026-08-31) | was `anvaiops/agentbrowser` (private); the owner chose to make it public and it moved to [anvai-labs/agentbrowser](https://github.com/anvai-labs/agentbrowser) on 2026-08-31 — raw per-target binaries + `sha256sums.txt` per release; the formula ships all four unix targets (CLI binary added in v1.8.2 alongside the MCP binary and server tarball) |
| ibkrtrading (anvaiops) | skip | private + no releases |
| inferflux | **live** (formula since 2026-09-06) | first release v0.1.0 (2026-09-04) initially published asset-less — tag pushes never ran CI, so the Release Packaging workflow (cpack tgz/deb/rpm/pkg/dmg/msi + `sha256sums.txt`) never fired; fixed by adding `v*` tag triggers to inferflux CI (PRs #79/#80) and re-cutting the tag. v0.1.1 (2026-09-07) added a native Linux-arm64 packaging leg upstream (PRs #92/#94). The formula ships the Darwin-arm64, Linux-x86_64, and Linux-aarch64 cpack tgz archives |
| victor verticals / registry / firmus / interviewer / stock-market-prediction / anvaiops | skip | Python libraries and services; `pipx`/`uv` remain the right installers |
| reasoning-engine / LLM-Inference-Service | skip | frameworks/services, not installable CLIs |
| legacy Java/Hadoop repos | skip | sample code, not products |

## Note on the old tap

`vjsingh1984/homebrew-tap` predates this one and was **transferred into the
`anvai-labs` org** — it is this repository, not a second tap (see the URL note
below). Install from `anvai-labs/tap`.

## For maintainers: bumping a formula on release

`sandhi`: run **Actions → Update Sandhi Formula** in this repository with the
new tag (e.g. `v0.2.1`) — it downloads the release assets, recomputes the
SHA-256s, and commits the formula update.

`sentinelpass`: run **Actions → Update SentinelPass Formula** in this
repository with the new tag (e.g. `v0.9.0`) — same flow as sandhi: it
downloads the release assets, recomputes the SHA-256s, and opens the bump PR
with a changed-file guard. The bot bumps **both** `Formula/sentinelpass.rb`
and `Casks/sentinelpass.rb` in one PR (skipping the cask on releases that
ship no zip), downloads everything into `RUNNER_TEMP`, and cross-checks the
zip sum against the release's `sha256sums.txt`. The manual procedure, if you
ever need to do it by hand — run it from a scratch clone of this tap:

```bash
V=<new version>   # e.g. V=0.8.0
curl -fsSL -o /tmp/sp-macos.tgz "https://github.com/anvai-labs/sentinelpass/releases/download/v${V}/sentinelpass-${V}-macos.tar.gz"
curl -fsSL -o /tmp/sp-linux.tgz "https://github.com/anvai-labs/sentinelpass/releases/download/v${V}/sentinelpass-${V}-linux.tar.gz"
curl -fsSL -o /tmp/sp.zip      "https://github.com/anvai-labs/sentinelpass/releases/download/v${V}/sentinelpass-${V}-macos-arm64.zip"
shasum -a 256 /tmp/sp-macos.tgz /tmp/sp-linux.tgz /tmp/sp.zip
curl -fsSL "https://github.com/anvai-labs/sentinelpass/releases/download/v${V}/sha256sums.txt"   # cross-check all three sums
```

then in the formula replace `v${V}` in both URLs (the tag path and the tarball
names) and set the two `sha256` lines (macOS sum first); in the cask rewrite
only the `version` stanza and the `sha256 arm:` line — the cask URL is fully
version-templated, and cask audit requires it to stay that way (a literal URL
is treated as unversioned). Nothing else changes. Keep the commands above:
they double as the diff-shape check (they reproduce the bot's exact change).
Asset names are arch-unnamed for the formula tarballs (`-macos.tar.gz` and
`-linux.tar.gz`, arm64/`x86_64`-only respectively), so until upstream renames
them per-arch the formula cannot cover more platforms than these. The cask
migrated from the arch-generic `-macos.dmg` to the arch-suffixed
`-macos-arm64.zip` with 0.18.0 (the first release shipping it, upstream #175).

Upstream's own release.yml "Bump Homebrew formula" job is retired for this
purpose: it pushed the bump directly to `main`, which checks-only branch
protection rejects (GH006, required "CI Success" — direct pushes can never
satisfy it), so it has failed on every release since v0.9.0. Bumps come from
this repository instead.

`victor`: automatic — `update-formula.yml` polls PyPI every 6 hours (it rewrites only the
sdist `url`/`sha256`). victor-ai itself is installed from that sdist; its PEP 517 build
backend (`setuptools`/`wheel`) and runtime dependency closure ship as pinned wheel resources
so `brew install` does not contact PyPI after Homebrew has fetched declared resources. After
a major bump that changes dependency constraints, regenerate them:
`tools/gen-victor-resources.py` (see its header) + `tools/assemble-victor-formula.py`, then
`brew style --fix Formula/victor.rb` and re-run `brew install && brew test`.

`inferflux`: run **Actions → Update Inferflux Formula** in this repository with the new tag
(e.g. `v0.1.1`) — same shape as the sandhi bot: it downloads the Darwin-arm64 and
Linux-x86_64 cpack tgz archives, recomputes the SHA-256s from the actual bytes, and commits
the formula update. Cross-check the two sums against the release's `sha256sums.txt`.

**Bot PRs start with no checks.** GitHub will not run workflows for PRs created
with the job token, so `automation/update-*` PRs sit checkless until nudged:
push one empty commit to the PR branch with a real token
(`git commit --allow-empty && git push`) — CI then runs and gates the merge as
usual. Same for reviewing: the bump diff must always be exactly the version
strings and `sha256` lines.

`dq-kernel` and `proximadb`: **Actions → Update data tools** accepts a product
and optional stable tag, and checks latest GitHub releases every six hours.
The updater downloads and hashes release bytes; dq-kernel regenerates its
entire Spark/Deequ dependency closure, including pinned build backends, and
ProximaDB verifies the archive against `SHA256SUMS.txt`. Updates open PRs and
explicitly run CI; they never merge automatically. Manual regeneration:

```bash
python3.12 scripts/update-dq-kernel.py --tag v0.1.0
python3 scripts/update-proximadb.py --tag v0.4.1
```

Since 2026-10-18, `proximadb` bumps are **upstream-driven in the normal
case**: proximaDB's release.yml `update-homebrew` job opens the PR here
itself, using the fine-grained PAT `proximadb-homebrew-tap-publish` (stored
as `HOMEBREW_TAP_TOKEN` on proximaDB; scoped to this tap only — Contents +
Pull requests read/write, nothing else). Its renderer rewrites the tap's
current formula `url`/`sha256` only (the same edit
`scripts/update-proximadb.py` makes, with the sha256 verified against both
`SHA256SUMS.txt` and the downloaded bytes), then the publisher waits for
this tap's required `CI Success` before squash-merging, rebasing onto
current `main` if it moved mid-CI. Direct pushes to `main` are never
attempted (branch protection rejects them, GH006). This tap's Update data
tools workflow remains the fallback: it opens the same PR within six hours
if the upstream job ran without the secret, and the manual commands above
always work. If both open a PR for the same version, whichever lands first
wins; close the other.

## Validation

CI runs on every push to `main` (and every PR): syntax + release-contract
checks, then `brew audit` on every formula followed by a real
`brew install` and `brew test` of each, against the checked-out tap on a Linux
runner. dq-kernel also gets a real macOS install and functional test. Casks get the same treatment on a macOS runner: `brew audit --cask`
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
