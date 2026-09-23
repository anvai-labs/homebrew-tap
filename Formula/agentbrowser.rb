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
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.10.0/agentbrowser-mcp-darwin-arm64"
    sha256 "57036b0e19d268b4fde83f4099b8eb9ede96f6c44aa754d3c3cb8ddd79af4812"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.10.0/agentbrowser-mcp-darwin-x64"
    sha256 "7b95c293f4c6ec1f35eae33b7d1c64907f429b30d94aec0bd449a539e7ade69e"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.10.0/agentbrowser-mcp-linux-arm64"
    sha256 "bc304f260265220ee83247ecb0aded8a996491f3e2a0e0f20d2d587750e431c7"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.10.0/agentbrowser-mcp-linux-x64"
    sha256 "f5b3e0ee4398b864b475f3f7d28336eb7bd83c6198a7079d6db08ae422b71fe4"
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
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.10.0/agentbrowser-server-darwin-arm64.tar.gz"
        sha256 "43bb209ba266435a03cd41fd72616f384277957c83b3fc78c2e53d08b07af4a1"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.10.0/agentbrowser-server-darwin-x64.tar.gz"
        sha256 "91ecef8e9fb5d0902482f7a0e4cc403bb70f9407720aab3ee602bb77af5b4a86"
      end
    end
    on_linux do
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.10.0/agentbrowser-server-linux-x64.tar.gz"
        sha256 "8a4451fc16b9b1ba44ecf4fbe38a3311f78784d93cf34268b67cd37fcec62227"
      end
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.10.0/agentbrowser-server-linux-arm64.tar.gz"
        sha256 "6e71f12d97baa42aae8e7951e85995e15c522e4974f99c5865ce61ff96689499"
      end
    end
  end

  resource "cli" do
    on_macos do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.10.0/agentbrowser-cli-darwin-arm64"
        sha256 "65bc633f68422ff2fa8fe248a01191eb2aa230475e363c24671e05509c1d2da7"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.10.0/agentbrowser-cli-darwin-x64"
        sha256 "3827f3cfedd08737bbd902b5db5de4e92174c3335b117738115f98271fc2b1cf"
      end
    end
    on_linux do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.10.0/agentbrowser-cli-linux-arm64"
        sha256 "e90bbbd7749c5d535b5c03da38235beec95713854b16ee3733bc0790f5b29c46"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.10.0/agentbrowser-cli-linux-x64"
        sha256 "fa745e8b1944b8bd5fe608e1cfd25bbbb36af9eb279b4260eb0cfd992a16759a"
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
                          session cookies ID --output FILE, session trace)
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
    system "#{bin}/agentbrowser", "--help"
    assert_equal version.to_s, shell_output("#{bin}/agentbrowser --version").strip
    assert_match "--cookies-file", shell_output("#{bin}/agentbrowser session create --help")
    assert_match "--output", shell_output("#{bin}/agentbrowser session cookies --help")
  end
end
