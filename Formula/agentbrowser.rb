# typed: false
# frozen_string_literal: true

class Agentbrowser < Formula
  desc "Agent-native browser service for AI agents (server + CLI + MCP server)"
  homepage "https://github.com/anvai-labs/agentbrowser"
  license "Apache-2.0"
  # Same 1.27.3 bottles; formula-only change (policy-file service wiring).
  revision 1

  # Prebuilt release artifacts: the agentbrowser-mcp executable (raw
  # per-target binaries) and, since v1.6.1, the API server as per-target
  # "fat tarballs" (built dist/ + pruned production node_modules — Playwright
  # is bundler-hostile, so the tree ships intact; see upstream #17). The
  # windows exe is not installable via brew. Versions are literal so brew
  # detects them from the URL; the Update Agentbrowser Formula workflow
  # rewrites them plus the sha256 lines.
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.3/agentbrowser-mcp-darwin-arm64"
    sha256 "b313d587180a9507ced092ed44d05c1613bd27f4f2dbb39bccfbf5a5e53cd123"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.3/agentbrowser-mcp-darwin-x64"
    sha256 "b431e2913a268879a3f4089e9c37e8a747772081ccfba0df1ef4b8826f0f1995"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.3/agentbrowser-mcp-linux-arm64"
    sha256 "21569c5fd1812cc75f8dbb7d7134b02f06e53f40be0103a2fd9f315a53819098"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.3/agentbrowser-mcp-linux-x64"
    sha256 "2e84c60e396e8e8067c84d5d533e468c700a1ebadb2a12e3e604629b5bd81df6"
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
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.3/agentbrowser-server-darwin-arm64.tar.gz"
        sha256 "34c5d48d49c655531bb5990502467298fbd864cb7d6b61f329e2acbca7dc0773"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.3/agentbrowser-server-darwin-x64.tar.gz"
        sha256 "dbf6e312d0a02befb166cc2f68673180309b6ea6d2a45db2110a18fa32b99b16"
      end
    end
    on_linux do
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.3/agentbrowser-server-linux-x64.tar.gz"
        sha256 "ab1a0e7665073d4aca3756c99e22c7c08a86312ca4d23117b24322c1057a7e28"
      end
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.3/agentbrowser-server-linux-arm64.tar.gz"
        sha256 "670884a254668f16806594324288a1688c8504cc0f3dc3cf4e121a0ce4495a95"
      end
    end
  end

  resource "cli" do
    on_macos do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.3/agentbrowser-cli-darwin-arm64"
        sha256 "5e9efdb3ba1cce47c07a0c66daa44ceba8c87f0815492b375fdbdc7253f0821e"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.3/agentbrowser-cli-darwin-x64"
        sha256 "3932d578cb5fc8e078de573e490f9021f647d27424741be9520f22a3efb694bc"
      end
    end
    on_linux do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.3/agentbrowser-cli-linux-arm64"
        sha256 "f73a43ec8a6647db6149655a7ab2cee55509bfad04039071e3c36151b476848f"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.27.3/agentbrowser-cli-linux-x64"
        sha256 "e0fdae419f53ce96b98b30af9f7c0afaad06dc315a4046f5af46c4994deaa0a6"
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

    # Service wrapper: keeps the Playwright browser cache under var,
    # bootstraps Chromium on first run (headless shell + browser, ~100 MB),
    # and sources the deployment env file under etc before exec. etc/
    # survives upgrades and brew never rewrites it, so per-install secrets
    # (API keys, operator-key path) placed there outlive the launchd plist,
    # which brew services regenerates from this formula on every start.
    node_bin = formula_opt_bin("node@24")/"node"
    (bin/"agentbrowser-server").write <<~EOS
      #!/bin/bash
      export PLAYWRIGHT_BROWSERS_PATH="${PLAYWRIGHT_BROWSERS_PATH:-#{var}/agentbrowser/browsers}"
      if ! compgen -G "$PLAYWRIGHT_BROWSERS_PATH/chromium*" >/dev/null 2>&1; then
        echo "agentbrowser-server: bootstrapping Chromium (one-time download)..." >&2
        PW_CLI="$(echo #{libexec}/node_modules/.pnpm/playwright@*/node_modules/playwright/cli.js)"
        "#{node_bin}" "$PW_CLI" install chromium 1>&2
      fi
      ENV_FILE="#{etc}/agentbrowser/env"
      if [ -f "$ENV_FILE" ]; then
        . "$ENV_FILE"
        export AGENTBROWSER_API_KEYS AGENTBROWSER_OPERATOR_KEYS_FILE AGENTBROWSER_LOGIN_BROWSER
      fi
      exec "#{node_bin}" "#{libexec}/dist/bin.js" "$@"
    EOS

    # Default Cedar policy document (policy-bearing env vars are deprecated
    # upstream; a file under etc/ survives upgrades). Equivalent to the old
    # AGENTBROWSER_MAX_RESPONSE_BYTES=33554432 baseline: capability permits,
    # approval classification, and a 32 MB response cap in `limits` (which
    # `policy export` does not emit — the reason it is written here whole).
    # Never clobber: an operator's edits and regenerated documents win.
    policy_dir = etc/"agentbrowser"
    policy_dir.mkpath
    policy_file = policy_dir/"policy.json"
    unless policy_file.exist?
      policy_file.write JSON.pretty_generate(
        version: "agentbrowser-policy/v1",
        baseline: "agentbrowser:baseline/v1",
        unknownRisk: "allow",
        approvalRules: [],
        limits: { maxResponseBytes: 33_554_432 },
        policies: [
          { key: "env.approval.unknown-risk#1",
            ruleId: "env.approval.unknown-risk",
            cedar: '@rule("env.approval.unknown-risk") permit(principal, action in ' \
                   '[AgentBrowser::Action::"act", AgentBrowser::Action::"act.unattended"], resource) ' \
                   'when { context.effect == "unknown" };' },
          { key: "env.approval.unknown-risk#2",
            ruleId: "env.approval.unknown-risk",
            cedar: '@rule("env.approval.unknown-risk") permit(principal, action == ' \
                   'AgentBrowser::Action::"act.unattended", resource) when { context.effect == "unknown" };' },
          { key: "env.approval.high-risk#3",
            ruleId: "env.approval.high-risk",
            cedar: '@rule("env.approval.high-risk") permit(principal, action == ' \
                   'AgentBrowser::Action::"act", resource) when { ["transaction", ' \
                   '"account-security", "external-message", "destructive"].contains(context.effect) };' },
          { key: "env.approval.high-risk#4",
            ruleId: "env.approval.high-risk",
            cedar: '@rule("env.approval.high-risk") forbid(principal, action == ' \
                   'AgentBrowser::Action::"act.unattended", resource) when { ["transaction", ' \
                   '"account-security", "external-message", "destructive"].contains(context.effect) };' },
          { key: "env.approval.default#5",
            ruleId: "env.approval.default",
            cedar: '@rule("env.approval.default") permit(principal, action in ' \
                   '[AgentBrowser::Action::"act", AgentBrowser::Action::"act.unattended"], resource) ' \
                   'when { !(["transaction", "account-security", "external-message", ' \
                   '"destructive", "unknown"].contains(context.effect)) };' },
          { key: "env.approval.default#6",
            ruleId: "env.approval.default",
            cedar: '@rule("env.approval.default") permit(principal, action == ' \
                   'AgentBrowser::Action::"act.unattended", resource) when { !(["transaction", ' \
                   '"account-security", "external-message", "destructive", ' \
                   '"unknown"].contains(context.effect)) };' },
          { key: "env.capability.default#7",
            ruleId: "env.capability.default",
            cedar: '@rule("env.capability.default") permit(principal, action in ' \
                   '[AgentBrowser::Action::"cdp.attach", AgentBrowser::Action::"downloads", ' \
                   'AgentBrowser::Action::"serviceWorkers", AgentBrowser::Action::"cookie.seed", ' \
                   'AgentBrowser::Action::"cookie.export", AgentBrowser::Action::"session.headed", ' \
                   'AgentBrowser::Action::"cookie.handoff"], resource);' }
        ]
      )
    end
  end

  service do
    run [opt_bin/"agentbrowser-server"]
    environment_variables "HOST" => "127.0.0.1",
                          "PORT" => "5709",
                          # Policy-bearing env (MAX_RESPONSE_BYTES etc.) is deprecated and
                          # cannot combine with a policy file; the document under etc is
                          # the one durable home for policy configuration.
                          "AGENTBROWSER_POLICY_FILE" => "#{etc}/agentbrowser/policy.json"
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

      Durable configuration lives under #{etc}/agentbrowser/ (brew never
      rewrites these on upgrade, unlike the launchd plist it regenerates):

        policy.json   the Cedar policy document the service loads
                      (AGENTBROWSER_POLICY_FILE). A default is installed
                      once; regenerate yours with
                      `agentbrowser-server policy export` and add the
                      "limits" object the export omits. Policy-bearing env
                      vars (ALLOW_LOOPBACK, ALLOWED_CIDRS, APPROVAL_POLICY,
                      MAX_RESPONSE_BYTES) are deprecated and refuse to
                      combine with it.
        env           optional shell fragment the server wrapper sources at
                      startup — put per-install secrets and wiring here so
                      they survive plist regeneration, e.g.:

                        export AGENTBROWSER_API_KEYS="<hex>:<tenant>"
                        export AGENTBROWSER_OPERATOR_KEYS_FILE="..."
                        export AGENTBROWSER_LOGIN_BROWSER=1

      Verify the loaded policy with `agentbrowser policy`.
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
