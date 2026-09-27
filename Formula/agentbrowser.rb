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
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.13.0/agentbrowser-mcp-darwin-arm64"
    sha256 "7238fe6e5dc49226df0506c8c6ac0acbe26109da80451851c38614bce4c58604"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.13.0/agentbrowser-mcp-darwin-x64"
    sha256 "8c3491b07c6e812795824a69ac3165a4a21de45478ed1aeb705e665cef791581"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.13.0/agentbrowser-mcp-linux-arm64"
    sha256 "8deb4846070a6b59eb6665a45966bbb651db2c6a2d6c21e6fee6fc413d81c89a"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.13.0/agentbrowser-mcp-linux-x64"
    sha256 "078af3fea64c2a90a5fd7e5e1cc7fcd6943d21c6e2811485a4bc0dfb56a3a6c9"
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
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.13.0/agentbrowser-server-darwin-arm64.tar.gz"
        sha256 "8b2490d22b059c9cc25c83d09d5f3fc7875954914f74d54ec2e15794e3446eff"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.13.0/agentbrowser-server-darwin-x64.tar.gz"
        sha256 "cfcd57a38e6c5af458cb2d68d24d2965839e0ecd1be7644ce660829f6622afd9"
      end
    end
    on_linux do
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.13.0/agentbrowser-server-linux-x64.tar.gz"
        sha256 "40cfcc70cb39400a0e21af11b1d33021738792287d2a1c2fc8f1c15348695c0f"
      end
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.13.0/agentbrowser-server-linux-arm64.tar.gz"
        sha256 "ee282de699546d3c5782e52bef16c2321dcc45a4f5517b5662b57be6a5fd840d"
      end
    end
  end

  resource "cli" do
    on_macos do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.13.0/agentbrowser-cli-darwin-arm64"
        sha256 "0ec983c769f8c961470a351b72c78071b199f89db6d79515caad3c578cef58ed"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.13.0/agentbrowser-cli-darwin-x64"
        sha256 "1f0ddaff0fe49b0bfd19d23aa896faa71c5daf740d2134a5d7d3637c9e0b683c"
      end
    end
    on_linux do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.13.0/agentbrowser-cli-linux-arm64"
        sha256 "06517df8cff1c1d51971b00c969ce4b6c20fca726d0bfb776699175f651854fa"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.13.0/agentbrowser-cli-linux-x64"
        sha256 "e78c8ef1651fc3d78aa35a13dc1829d1f54547da2d57b440bccdc8e83c28147b"
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
