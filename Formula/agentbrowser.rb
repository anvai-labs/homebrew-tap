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
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.1/agentbrowser-mcp-darwin-arm64"
    sha256 "ddd0d8f96df8ac14868412c9927a22c95b724f5837cd482eeef5cbb678097468"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.1/agentbrowser-mcp-darwin-x64"
    sha256 "0963ad728d9e3cd63587579e1e8b76ccf2875301687825eedf03d383d01264af"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.1/agentbrowser-mcp-linux-arm64"
    sha256 "6cee108035c84cff8e414799397cbc501be6d61a7daedf013b14e51d3d6d07fb"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.1/agentbrowser-mcp-linux-x64"
    sha256 "1bb01cd8313825348eb73319388b55e7ff992255f47669f98d7347fe1223c42e"
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
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.1/agentbrowser-server-darwin-arm64.tar.gz"
        sha256 "280ba43354d8bec4b8c31159037f49d6b3f09cd84da73b1dbf38a3977ab6a916"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.1/agentbrowser-server-darwin-x64.tar.gz"
        sha256 "807e98033721ab0e808b026fdc7334a6daeefd1ac7545c125f82191dd49f7e35"
      end
    end
    on_linux do
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.1/agentbrowser-server-linux-x64.tar.gz"
        sha256 "a67f7babf3384c154d2ad5ce441da95f4c5e5d4bb54998b8c955c92895cee405"
      end
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.8.1/agentbrowser-server-linux-arm64.tar.gz"
        sha256 "29c394c88aad1f44d9dcbde358021f9cbaa67f99218e90bf86f2837639c90362"
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
