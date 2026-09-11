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
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.9/agentbrowser-mcp-darwin-arm64"
    sha256 "fcb6d37f1190e9282743039271b10aac925c55b390ad6989533a4f603633366c"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.9/agentbrowser-mcp-darwin-x64"
    sha256 "3f6c103fd3c8fcc75bb732f4fd937230bd9bc418faad22c144c0247bfe156a62"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.9/agentbrowser-mcp-linux-arm64"
    sha256 "88f6cd66ba31c0885de9977552d39ff4ec82a3e4a4c5de6f2abc1de3e3f1b07e"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.9/agentbrowser-mcp-linux-x64"
    sha256 "d0c327c033d55758c7163396979dccb6d32b4fbf288c10290366c589d9c75baf"
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
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.9/agentbrowser-server-darwin-arm64.tar.gz"
        sha256 "bddb8f1b8aca47acbd5033a1120899fe680f755878ee6eefd4d38996720c11f2"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.9/agentbrowser-server-darwin-x64.tar.gz"
        sha256 "22fb88e27bed1e16bbafc0cf1b39a47d44f376e2371ffd27e2fb1be4284e569a"
      end
    end
    on_linux do
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.9/agentbrowser-server-linux-x64.tar.gz"
        sha256 "4d0d9f63737dba919e6081f7cd33cc200deb0603c720bb004a4f01f2717cb253"
      end
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.9/agentbrowser-server-linux-arm64.tar.gz"
        sha256 "56daccd999dd17ff72dea2165bd4079e6e72255d02b8a68ff36a42ee56cc5323"
      end
    end
  end

  resource "cli" do
    on_macos do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.9/agentbrowser-cli-darwin-arm64"
        sha256 "a91924b448509a30be2838fdb4c83ac2804a25d8436a72010de6733e64427830"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.9/agentbrowser-cli-darwin-x64"
        sha256 "8b5e519f355f19e4a2cba8e5d7a6cca053cb0b28cdb9a64adf1884c57c1b5fff"
      end
    end
    on_linux do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.9/agentbrowser-cli-linux-arm64"
        sha256 "06530d7169d6d7c5bf6bfbc3ea57248000ad88d55d815ce66fa2534059351cab"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.9/agentbrowser-cli-linux-x64"
        sha256 "96453f1330d8a6ec3f8902dece376761beb4ea403fc683f129860fb4a5610318"
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
