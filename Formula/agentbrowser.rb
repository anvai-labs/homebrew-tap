# typed: false
# frozen_string_literal: true

class Agentbrowser < Formula
  desc "Agent-native browser service for AI agents (server + CLI + MCP server)"
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
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.7/agentbrowser-mcp-darwin-arm64"
    sha256 "240c0a5d4ad2536fc6e53da58fb55c62fee1f2b45aabefdce531c4845b2aa989"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.7/agentbrowser-mcp-darwin-x64"
    sha256 "9380319ab5ab662b8030c2f307d9ed0a01dca8cccb2efdaf69c5d1857a94288f"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.7/agentbrowser-mcp-linux-arm64"
    sha256 "855072d6d1fbc58dfd4ebce902370f73c9507ea2be9461e18629f2e507005f40"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.7/agentbrowser-mcp-linux-x64"
    sha256 "6939c44d36d98db43acd484a971503bd1009c72c1fc07fef10505837ff997482"
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
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.7/agentbrowser-server-darwin-arm64.tar.gz"
        sha256 "e41e74a26d49182885faaf3b13e34127d6881d42ecd0da374229e80ef31a29b9"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.7/agentbrowser-server-darwin-x64.tar.gz"
        sha256 "246dfe92f0730635961e4b88db374896c3c6193d5a08ddc2065acb8c35408d67"
      end
    end
    on_linux do
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.7/agentbrowser-server-linux-x64.tar.gz"
        sha256 "ede675be38802f10e5c8dbf10f72dc9f6b4cc5413c89c50e130706e8856a2b19"
      end
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.7/agentbrowser-server-linux-arm64.tar.gz"
        sha256 "db1576061a5c1c02705a65540a609dbd4934723c585b0a1d174755805281edcc"
      end
    end
  end

  resource "cli" do
    on_macos do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.7/agentbrowser-cli-darwin-arm64"
        sha256 "0996a4fe8165ac918abe3150cc25be7969ab4950df8c8d72aadbd7a93840ecc3"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.7/agentbrowser-cli-darwin-x64"
        sha256 "02d09137a24c5f80e703f13f4e1199d8e8a12fd337de01de55f85a913b2e0b1c"
      end
    end
    on_linux do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.7/agentbrowser-cli-linux-arm64"
        sha256 "be1c82a7bedbdf33b357ed1596253173c68ddfb8d085dc0fb13ad7c1cad167ac"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.7/agentbrowser-cli-linux-x64"
        sha256 "3766f920ca533e4fcd56f44007b1dbd326fa536852324f3bc61cde4649f51bfe"
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

    resource("cli").stage do
      cli_target = if OS.mac?
        Hardware::CPU.arm? ? "agentbrowser-cli-darwin-arm64" : "agentbrowser-cli-darwin-x64"
      else
        Hardware::CPU.arm? ? "agentbrowser-cli-linux-arm64" : "agentbrowser-cli-linux-x64"
      end
      bin.install cli_target => "agentbrowser"
    end

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
      One install, all three:

        the service:     brew services start anvai-labs/tap/agentbrowser
                         (listens on 127.0.0.1:3000; first start bootstraps
                         Chromium into var/agentbrowser/browsers)
        the CLI:         #{opt_bin}/agentbrowser --help
                         (session create --no-headless --idle-timeout 3600000,
                          snapshot/plan, session cookies, session trace)
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
    system "#{bin}/agentbrowser", "--help"
  end
end
