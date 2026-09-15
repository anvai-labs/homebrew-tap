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
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.14/agentbrowser-mcp-darwin-arm64"
    sha256 "b3f79aaf5196e7a621e97cdeea3479e1f0422e52d0dfd364495f1140a2b9cb8c"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.14/agentbrowser-mcp-darwin-x64"
    sha256 "7ec51af96da912c8597c5bc2904664178d4f3ed0af7916c9af3c63afd62723ca"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.14/agentbrowser-mcp-linux-arm64"
    sha256 "5c72ba9ca00067a3f7703fe03cd755aa326d8dac7af6b6ae618ba96c0a804176"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.14/agentbrowser-mcp-linux-x64"
    sha256 "81355331ac0070731b6e18734b9b1975eff01be6005e9ba8ae47e8cce1a9833a"
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
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.14/agentbrowser-server-darwin-arm64.tar.gz"
        sha256 "8503c466f36bf304274af38a242c01d30ca1b4e70db6b9c73f8671b0aa110bc6"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.14/agentbrowser-server-darwin-x64.tar.gz"
        sha256 "af7c2c253d5194a2b943d834fb4188fe1a0dfa263a745e6080785e9bf8b8c186"
      end
    end
    on_linux do
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.14/agentbrowser-server-linux-x64.tar.gz"
        sha256 "ce638f06bf67514c71310b65ca95db5cb8cc4846747a119057d5b530c56019c1"
      end
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.14/agentbrowser-server-linux-arm64.tar.gz"
        sha256 "08cbb01d26039f651d669de1bd407b9e43a9ca06c623784cf98f9b6f1dd6361b"
      end
    end
  end

  resource "cli" do
    on_macos do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.14/agentbrowser-cli-darwin-arm64"
        sha256 "8d50b8443949b6cd4df4c5880e5ab58bd83ccdaa9c35246732541579c5cafa80"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.14/agentbrowser-cli-darwin-x64"
        sha256 "d3b3487f51d3fee96d618da93c94ebe18dd4d60acf8bcc7bad79e22528ee7f32"
      end
    end
    on_linux do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.14/agentbrowser-cli-linux-arm64"
        sha256 "3a5ab1a277321296f9c943480a0dcd97cbb30d31ee13927f8bd84b709648a15d"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.14/agentbrowser-cli-linux-x64"
        sha256 "8d657eb00787e13026eb335bd052941e6cd03a4deef2efb140a1419fde6accd6"
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
      http://localhost:5709; override with AGENTBROWSER_BASE_URL,
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
