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

### Not here (yet), and why

- **proximaDB** — a database server with no macOS build; its own deb/rpm/msi
  cover Linux and Windows. A formula would be Linuxbrew-only.
- **victor verticals / registry** — Python libraries and services; `pipx`/`uv`
  remain the right installers.
- **inferflux** — no releases published.

## Note on the old tap

`vjsingh1984/homebrew-tap` predates this one and carries a mirror of
`victor.rb`. It is frozen; install from `anvai-labs/tap` (this repository).

## For maintainers: bumping a formula on release

`sandhi`: run **Actions → Update Sandhi Formula** in this repository with the
new tag (e.g. `v0.2.1`) — it downloads the release assets, recomputes the
SHA-256s, and commits the formula update.

`sentinelpass`: edit `Formula/sentinelpass.rb` (`version` + the two `sha256`
lines; the sums are also published in each release's `sha256sums.txt`).

`victor`: automatic — `update-formula.yml` polls PyPI every 6 hours.

## Validation

CI runs `brew audit` and install tests on every formula on push to `main`.

## Note on the old tap URL

Instructions older than 2026-08 may say `brew tap vjsingh1984/tap`. That
repository was transferred to the `anvai-labs` org, and GitHub redirects the
old URL here permanently — old instructions keep working, and
`anvai-labs/tap` is the single authoritative source.
