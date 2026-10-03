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
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.15.1/agentbrowser-mcp-darwin-arm64"
    sha256 "fc71115d6756ff42e3b2487028c30155d0e8e707ea7815c20d9b829b7ec2ebed"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.15.1/agentbrowser-mcp-darwin-x64"
    sha256 "91f04a4ed44424a5f093430015f4ec79e843cb7f49a27fa1e79635a74fff037c"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.15.1/agentbrowser-mcp-linux-arm64"
    sha256 "4f0de24c7cf3b65c8654690c5727e4f1cb9dd390dca5a69e409a705ba614916a"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.15.1/agentbrowser-mcp-linux-x64"
    sha256 "b49acd5d95956b578d76c4eef4b33daabc63952818554b47d5f11b6c3f8489d4"
  end

  livecheck do
    url "https://github.com/anvai-labs/agentbrowser/releases/latest"
    strategy :header_match
    regex(%r{/tag/v?(\d+(?:\.\d+)+)$}i)
  end

  depends_on "node@24"

  resource "server" do
    on_macos do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.15.1/agentbrowser-server-darwin-arm64.tar.gz"
        sha256 "c0578eb808f0e397a7bb13d9e8755593a1e7badcf893e98582202fa87937b035"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.15.1/agentbrowser-server-darwin-x64.tar.gz"
        sha256 "11c680ed9f07962f7ec181870a9edaa67fcfe35123218bb9759de332ba3e882a"
      end
    end
    on_linux do
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.15.1/agentbrowser-server-linux-x64.tar.gz"
        sha256 "c5c5d2d3fef7776d1c5e024ea40667f8b3fded8feb78f3113914154f8746ba8a"
      end
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.15.1/agentbrowser-server-linux-arm64.tar.gz"
        sha256 "976fc1afc355acdff9404b41655fea41a9f2906eefe7c94a986bfaa5d8dd3c23"
      end
    end
  end

  resource "cli" do
    on_macos do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.15.1/agentbrowser-cli-darwin-arm64"
        sha256 "87540aeaa8e72f945f4c7499920a8267c8a28a5ee7b52dd1625eb9a1831efbb9"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.15.1/agentbrowser-cli-darwin-x64"
        sha256 "70bc2444387365275c8cfcaea51f17e65de479465a481dd4702f44499c8c06ba"
      end
    end
    on_linux do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.15.1/agentbrowser-cli-linux-arm64"
        sha256 "23bea688e2a94cb7ce172177db99f48b65e40c16cf6a3e165bd1455b14dd89d3"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.15.1/agentbrowser-cli-linux-x64"
        sha256 "099beaf2881fcd1d4005752ceca74f81cc2abcdc80a7e75c1c1c085a47f7dc21"
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
    node_bin = formula_opt_bin("node@24")/"node"
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
                          "PORT" => "5709"
    keep_alive true
    log_path var/"log/agentbrowser-server.log"
    error_log_path var/"log/agentbrowser-server.err.log"
  end

  def caveats
    <<~EOS
      One install, all three:

        the service:     brew services start anvai-labs/tap/agentbrowser
                         (listens on 127.0.0.1:5709; first start bootstraps
                         Chromium into var/agentbrowser/browsers)
        the CLI:         #{opt_bin}/agentbrowser --help
                         (session create --no-headless --idle-timeout 3600000,
                          snapshot/plan, session create --cookies-file FILE,
                          session cookies ID --output FILE, session trace;
                          session get ID for launch diagnostics, page create/list,
                          extract --max-bytes N for bounded complete output)
        the MCP server:  spawn #{opt_bin}/agentbrowser-mcp — no args (stdio)

      Wire up an MCP client:

        Claude Code:
          claude mcp add agentbrowser -- #{opt_bin}/agentbrowser-mcp
        Claude Desktop (claude_desktop_config.json):
          {"mcpServers": {"agentbrowser": {"command": "#{opt_bin}/agentbrowser-mcp"}}}
        Codex (~/.codex/config.toml):
          [mcp_servers.agentbrowser]
          command = "#{opt_bin}/agentbrowser-mcp"

      The clients drive the service (default http://localhost:5709;
      CLI override: --base-url; MCP override: AGENTBROWSER_BASE_URL),
      authenticate with AGENTBROWSER_API_KEY — set keys via the service's
      AGENTBROWSER_API_KEYS env in a launchd override if you expose it.
    EOS
  end

  test do
    # agentbrowser-mcp is a stdio MCP server: given an open stdin it starts
    # serving and never exits, so probe it with stdin closed.
    system "/bin/sh", "-c", %Q("#{bin}/agentbrowser-mcp" --help </dev/null)
    system bin/"agentbrowser", "--help"
    assert_equal version.to_s, shell_output("#{bin}/agentbrowser --version").strip
    assert_match "--cookies-file", shell_output("#{bin}/agentbrowser session create --help")
    assert_match "--output", shell_output("#{bin}/agentbrowser session cookies --help")
    assert_match "session get", shell_output("#{bin}/agentbrowser session get --help")
    assert_match "page create", shell_output("#{bin}/agentbrowser page create --help")
    assert_match "page list", shell_output("#{bin}/agentbrowser page list --help")
    assert_match "--max-bytes", shell_output("#{bin}/agentbrowser extract --help")
  end
end
