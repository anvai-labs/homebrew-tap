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
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.2/agentbrowser-mcp-darwin-arm64"
    sha256 "5a6cbb5a7ea80dec46b3fbad801d50a7cb85c802e2cc8f1786e816aa6856e7f0"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.2/agentbrowser-mcp-darwin-x64"
    sha256 "994352c555fae0ee2c0be2c2d62b3617f4a7ba274017147a0e9216afe0fb82d4"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.2/agentbrowser-mcp-linux-arm64"
    sha256 "27f95da70700c5029bcf23741b3c8a8b0bf3e97cd58f11dd742087770cbbf0ff"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.2/agentbrowser-mcp-linux-x64"
    sha256 "0b65fc33a2201dee3983f78e47468c6c2e26c0b14a4fd9055967c016bd741662"
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
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.2/agentbrowser-server-darwin-arm64.tar.gz"
        sha256 "8962e188c022c15a38418f660c9c56e4f03bcfc74bca9c5746433d4057c7e098"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.2/agentbrowser-server-darwin-x64.tar.gz"
        sha256 "34cafe02f5c88b5e64335875b21b35ec8242cfc425f35ce7afd791e710dcf330"
      end
    end
    on_linux do
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.2/agentbrowser-server-linux-x64.tar.gz"
        sha256 "d08865d7547b0e23d4dfba741aa5a31d011ba0df074295583d58d08312b6a9c7"
      end
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.2/agentbrowser-server-linux-arm64.tar.gz"
        sha256 "7ec04949f425f546695920e15361ef660b6098564b95abbae6e3fa57c64fa4dd"
      end
    end
  end

  resource "cli" do
    on_macos do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.2/agentbrowser-cli-darwin-arm64"
        sha256 "4507664f5bc6b70598696c4f6857b97794f9cd170c7e28b961de6a4a52e9f1f3"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.2/agentbrowser-cli-darwin-x64"
        sha256 "59f0823a3dcd36909853be86fe3691835f7c83214526cf7d0babe92e962e69b7"
      end
    end
    on_linux do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.2/agentbrowser-cli-linux-arm64"
        sha256 "4e925e62f2ba4f238f74c0a4ced3e11f56f56443e0b7fd8cf970972e8eae16c9"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.2/agentbrowser-cli-linux-x64"
        sha256 "32f581b4abc8099ea673767537ec72e1eca8a6721afb74008721b6dc70ea5185"
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
