# typed: false
# frozen_string_literal: true

class Agentbrowser < Formula
  desc "Agent-native browser service for AI agents (server + MCP server)"
  homepage "https://github.com/anvai-labs/agentbrowser"
  license "Apache-2.0"

  # Prebuilt release artifacts: the agentbrowser-mcp executable (raw
  # per-target binaries) and, since v1.6.1, the API server as per-target
  # "fat tarballs" (built dist/ + pruned production node_modules — Playwright
  # is bundler-hostile, so the tree ships intact; see upstream #17). The
  # windows exe is not installable via brew. Versions are literal so brew
  # detects them from the URL; the Update Agentbrowser Formula workflow
  # rewrites them plus the sha256 lines.
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.7.0/agentbrowser-mcp-darwin-arm64"
    sha256 "77465972b2ecafea88a21f6fc28519a2c66d7d66f3c0d7a36090ece5834381db"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.7.0/agentbrowser-mcp-darwin-x64"
    sha256 "578ce3d068e0e1a14fc307c326fb3aa5f809922c62a15ad81909d93304c54c61"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.7.0/agentbrowser-mcp-linux-arm64"
    sha256 "345dcb50c90e86bf9eb1a849a9e673bdd65afac0f46a1ecf1903ca4734d7c63a"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.7.0/agentbrowser-mcp-linux-x64"
    sha256 "84dc4b04aa003040c93e2f87b283fd211c11829e4e96d3872da38a5d66306d80"
  end

  livecheck do
    url "https://github.com/anvai-labs/agentbrowser/releases/latest"
    strategy :header_match
    regex(%r{/tag/v?(\d+(?:\.\d+)+)$}i)
  end

  depends_on "node@22"

  resource "server" do
    on_macos do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.7.0/agentbrowser-server-darwin-arm64.tar.gz"
        sha256 "b8afd96aed2e9f522cef1abc036b6ebbea0fd8bcffbc0b9e2afe8713f0b8028b"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.7.0/agentbrowser-server-darwin-x64.tar.gz"
        sha256 "8016ba7d64a2796ed9d81c94986532f5581c750f16a632680aca5d7f1bb7cb96"
      end
    end
    on_linux do
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.7.0/agentbrowser-server-linux-x64.tar.gz"
        sha256 "15efd921382dd277e53a2a916e429ca23f36871b792471e96f61f7e8fe255363"
      end
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.7.0/agentbrowser-server-linux-arm64.tar.gz"
        sha256 "7f2edba8efabe03052e2e29ecba39aff7430a8ebfad7eaf3f56d0ee57f657c34"
      end
    end
  end

  def install
    target = if OS.mac?
      Hardware::CPU.arm? ? "agentbrowser-mcp-darwin-arm64" : "agentbrowser-mcp-darwin-x64"
    else
      Hardware::CPU.arm? ? "agentbrowser-mcp-linux-arm64" : "agentbrowser-mcp-linux-x64"
    end
    bin.install target => "agentbrowser-mcp"

    resource("server").stage do
      libexec.install Dir["*"]
    end

    # Service wrapper: keeps the Playwright browser cache under var and
    # bootstraps Chromium on first run (headless shell + browser, ~100 MB).
    node_bin = formula_opt_bin("node@22")/"node"
    (bin/"agentbrowser-server").write <<~EOS
      #!/bin/bash
      export PLAYWRIGHT_BROWSERS_PATH="${PLAYWRIGHT_BROWSERS_PATH:-#{var}/agentbrowser/browsers}"
      if ! compgen -G "$PLAYWRIGHT_BROWSERS_PATH/chromium*" >/dev/null 2>&1; then
        echo "agentbrowser-server: bootstrapping Chromium (one-time download)..." >&2
        PW_CLI="$(echo #{libexec}/node_modules/.pnpm/playwright@*/node_modules/playwright/cli.js)"
        "#{node_bin}" "$PW_CLI" install chromium 1>&2
      fi
      exec "#{node_bin}" "#{libexec}/dist/bin.js" "$@"
    EOS
  end

  service do
    run [opt_bin/"agentbrowser-server"]
    environment_variables "HOST" => "127.0.0.1",
                          "PORT" => "3000"
    keep_alive true
    log_path var/"log/agentbrowser-server.log"
    error_log_path var/"log/agentbrowser-server.err.log"
  end

  def caveats
    <<~EOS
      One install, both halves:

        the service:     brew services start anvai-labs/tap/agentbrowser
                         (listens on 127.0.0.1:3000; first start bootstraps
                         Chromium into var/agentbrowser/browsers)
        the MCP server:  spawn #{opt_bin}/agentbrowser-mcp — no args (stdio)

      Wire up an MCP client:

        Claude Code:
          claude mcp add agentbrowser -- #{opt_bin}/agentbrowser-mcp
        Claude Desktop (claude_desktop_config.json):
          {"mcpServers": {"agentbrowser": {"command": "#{opt_bin}/agentbrowser-mcp"}}}
        Codex (~/.codex/config.toml):
          [mcp_servers.agentbrowser]
          command = "#{opt_bin}/agentbrowser-mcp"

      The browser tools drive the service (default
      http://localhost:3000; override with AGENTBROWSER_BASE_URL,
      authenticate with AGENTBROWSER_API_KEY — set keys via the service's
      AGENTBROWSER_API_KEYS env in a launchd override if you expose it).
    EOS
  end

  test do
    # agentbrowser-mcp is a stdio MCP server: given an open stdin it starts
    # serving and never exits, so probe it with stdin closed.
    system "/bin/sh", "-c", %Q("#{bin}/agentbrowser-mcp" --help </dev/null)
  end
end
