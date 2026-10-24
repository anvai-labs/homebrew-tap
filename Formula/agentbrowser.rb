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
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.2/agentbrowser-mcp-darwin-arm64"
    sha256 "7348611904b656dd528802836d8bd0c2a2ae2b4d2200c13c2162d352be73dd74"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.2/agentbrowser-mcp-darwin-x64"
    sha256 "0399b96e04abf264501e9ee29c1bcbc7689972cdce6cb5fb52b857c744460c6d"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.2/agentbrowser-mcp-linux-arm64"
    sha256 "2a9a3f7f867d4097fc7ec540052895021e34fe48ea7417bb00d141dba41ab09e"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.2/agentbrowser-mcp-linux-x64"
    sha256 "c1cb3b858d8f5ed00d50882afef5f6db497bf56811d539586b85b07eab24d92e"
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
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.2/agentbrowser-server-darwin-arm64.tar.gz"
        sha256 "6d5aa84c3e800ca1a11dc471aefdc5c0b2724fd26d6a7215ac8bf32c59b6876f"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.2/agentbrowser-server-darwin-x64.tar.gz"
        sha256 "3a4d033d07060e576efaef8ecb637991456af754b6f244eddbde5dcb0ec948d2"
      end
    end
    on_linux do
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.2/agentbrowser-server-linux-x64.tar.gz"
        sha256 "13a6b96317e7d630a3b679a76fc3a5b981d6e80d9a949c125d1aa997ff95d3c7"
      end
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.2/agentbrowser-server-linux-arm64.tar.gz"
        sha256 "612abff230d1825e39cbe877522d20b352af4fcf515969da8d4fc668b9bea8fe"
      end
    end
  end

  resource "cli" do
    on_macos do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.2/agentbrowser-cli-darwin-arm64"
        sha256 "15c1b691df340fc750736511a36e8acc068de590845bd5b64646549ca41b1a23"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.2/agentbrowser-cli-darwin-x64"
        sha256 "3161bebacdb556ada417f8975258f15a820cdc1ecbd2d34790073c4b96a26980"
      end
    end
    on_linux do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.2/agentbrowser-cli-linux-arm64"
        sha256 "fbded7c3b518adcbf9db879f80b8bdb5730e33696adcf2df72b16e201ad6a739"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.2/agentbrowser-cli-linux-x64"
        sha256 "5d88acc1b53bfee7651f4e4b13c58c86a6f1ba7f2bbaa121ecfe27e9317ffdb5"
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
