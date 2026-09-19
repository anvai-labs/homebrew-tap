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
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.9.0/agentbrowser-mcp-darwin-arm64"
    sha256 "90b1eafe2a3b902e5d2186eb37fbc6ca77a3d97bf9e4d0a1f42830fb7068fde7"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.9.0/agentbrowser-mcp-darwin-x64"
    sha256 "816766ab21c3c0f10d3c3de4972673d165e6baf86bd5d9010cc3f9678ee5f6f2"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.9.0/agentbrowser-mcp-linux-arm64"
    sha256 "1a9fc85c83f27cf21519444a910f7d0ae3281b82672d22f4cb4ef260692eaa54"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.9.0/agentbrowser-mcp-linux-x64"
    sha256 "9151605e67f62feee3c37cc3e099b8d9ba2dbac6dcfa477fcde7ec5dc71549c0"
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
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.9.0/agentbrowser-server-darwin-arm64.tar.gz"
        sha256 "5a459d0ab2070d72200d85373535a05f8150a8a216259edd9cb4b07a63e10412"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.9.0/agentbrowser-server-darwin-x64.tar.gz"
        sha256 "0c25e94626b8726c9f7cb1d95ea9c893c29622fc67869fc582553b2ba080603a"
      end
    end
    on_linux do
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.9.0/agentbrowser-server-linux-x64.tar.gz"
        sha256 "f071c3b399d54c202490c8cea318162b21bc819b23daec2ab5f6a94ca5c91176"
      end
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.9.0/agentbrowser-server-linux-arm64.tar.gz"
        sha256 "6c81179af415ce8ec834d606d7885d3ca5c7e5e4fc2e9307b08a3c60a29d2acb"
      end
    end
  end

  resource "cli" do
    on_macos do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.9.0/agentbrowser-cli-darwin-arm64"
        sha256 "1902a0443837c6d4fcc044cf9c717ff0b42f129d67c117e644967081ae5fdc58"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.9.0/agentbrowser-cli-darwin-x64"
        sha256 "022c84c4d1f8a870640a5ce9337b57a99c5b039a4d1f556aa59ac4759b2495e7"
      end
    end
    on_linux do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.9.0/agentbrowser-cli-linux-arm64"
        sha256 "4aa06e92faba00b0e741ced46acbfd2e6f440d2c770fbc37ab5288585add5ee7"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.9.0/agentbrowser-cli-linux-x64"
        sha256 "1cee73dd5f9300568f148e36e529182301e6ec2ff5d141d05feffd9ac319789b"
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
