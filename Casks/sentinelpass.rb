cask "sentinelpass" do
  version "0.13.0"
  # Arm64-only upstream; the DMG asset name is arch-generic. The sum is
  # recomputed from the actual downloaded DMG and cross-checked against the
  # release's sha256sums.txt on every bump.
  sha256 arm: "b487df257a56b1881b10df2dde4c2fbb5aac8c1b7f359b00769754f798452a5a"

  url "https://github.com/anvai-labs/sentinelpass/releases/download/v#{version}/sentinelpass-#{version}-macos.dmg",
      verified: "github.com/anvai-labs/sentinelpass/"
  name "SentinelPass"
  desc "Local-first password manager with browser autofill (desktop app)"
  homepage "https://github.com/anvai-labs/sentinelpass"

  livecheck do
    url "https://github.com/anvai-labs/sentinelpass/releases/latest"
    strategy :header_match
    regex(%r{/tag/v?(\d+(?:\.\d+)+)$}i)
  end

  # Upstream ships arm64 macOS only (no Intel/universal2 build exists); the
  # arch-generic DMG name must not suggest otherwise.
  depends_on arch: :arm64

  # The .app is self-contained: it embeds and manages its own daemon and
  # browser native-messaging host (Contents/Resources/src-tauri/resources/bin)
  # and owns the daemon lifecycle. No `binary` stanzas on purpose — the CLI
  # tools belong to Formula/sentinelpass.rb, and a cask binary would collide
  # with the formula's /opt/homebrew/bin/sentinelpass-ui.
  app "SentinelPass.app"

  uninstall quit: "com.sentinelpass.app"

  zap trash: [
    # The vault lives in ~/Library/Application Support/PasswordManager and
    # MUST survive uninstall and --zap (upstream docs/MACOS_INSTALL.md).
    "~/Library/Caches/com.sentinelpass.app",
    "~/Library/WebKit/com.sentinelpass.app",
    "~/Library/HTTPStorages/com.sentinelpass.app",
    "~/Library/Saved Application State/com.sentinelpass.app.savedState",
  ]

  caveats <<~EOS
    This cask installs the SentinelPass desktop app only. The command-line
    tools (sentinelpass, sentinelpass-host, sentinelpass-ui) come from the
    formula: brew install anvai-labs/tap/sentinelpass

    The app manages its own daemon and the vault at
    ~/Library/Application Support/PasswordManager. Uninstall — even
    brew uninstall --zap --cask sentinelpass — never touches the vault.

    If you also install the formula, keep both channels on the same release:
    whichever UI launched last re-points the browser native-messaging
    manifests at its own host copy (harmless when versions match).

    The app is currently ad-hoc signed, not Developer ID notarized (upstream
    issue #148). Homebrew quarantines cask installs, so the first launch may
    report SentinelPass as "damaged" until upstream ships a notarized build.
    See https://github.com/anvai-labs/sentinelpass/blob/main/docs/MACOS_INSTALL.md
  EOS
end
