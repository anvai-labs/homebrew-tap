cask "sentinelpass" do
  # The version stanza is the single source of truth for bumps: the URL is
  # fully version-templated (cask audit requires a versioned URL), so the
  # bump bot rewrites only this stanza and the arm checksum below.
  version "0.13.3"
  # Arm64-only upstream; the DMG asset name is arch-generic. The sum is
  # recomputed from the actual downloaded DMG and cross-checked against the
  # release's sha256sums.txt on every bump.
  sha256 arm: "6d5ea13526264770e3c0338f9ce634bef671a80838e33b2b4bb38ff6a7090d96"

  url "https://github.com/anvai-labs/sentinelpass/releases/download/v#{version}/sentinelpass-#{version}-macos.dmg"
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
    The desktop app bundles its daemon and browser native-messaging host.
    No formula installation is needed for desktop or browser use.

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
