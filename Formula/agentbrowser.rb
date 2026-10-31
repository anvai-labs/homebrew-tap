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
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.29.1/agentbrowser-mcp-darwin-arm64"
    sha256 "5782b4a862cbdd91eeb38f57be6104f3a80b80a7bc58a85066a759d13af02b5d"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.29.1/agentbrowser-mcp-darwin-x64"
    sha256 "5e6a40e1ae6ddb0e2bd9b8bb04c813c082e59bd2e0fbc641b115f56f2898faad"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.29.1/agentbrowser-mcp-linux-arm64"
    sha256 "9380d1f262fbbe24decce553c457e680d27bddc546596dd5f433c9dba55db1b4"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.29.1/agentbrowser-mcp-linux-x64"
    sha256 "3b9e110267ebf46bfd1456c1652aa507de4ae8942b5e1f373c8a3e693d189c4b"
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
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.29.1/agentbrowser-server-darwin-arm64.tar.gz"
        sha256 "60de97b6e7ded76bcbb104e1d5919409f1b4427cecb567da18bd036e8ecc4174"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.29.1/agentbrowser-server-darwin-x64.tar.gz"
        sha256 "eb86a7bfc0b0a1e0cc8eabccd534228eb6dbb130c8802b69fa47cfce6e0f1bad"
      end
    end
    on_linux do
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.29.1/agentbrowser-server-linux-x64.tar.gz"
        sha256 "2b3e6186f5d2c9bc5815332d873307274809ee645de101090ca3397dd3fc873d"
      end
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.29.1/agentbrowser-server-linux-arm64.tar.gz"
        sha256 "e0b21adffd3ba308e9065b0fae189a50d17e617a9045d6660510781b8275a9e5"
      end
    end
  end

  resource "cli" do
    on_macos do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.29.1/agentbrowser-cli-darwin-arm64"
        sha256 "ffdff8733dea97a6e32cafcde391a3ec33dfa7cd897cae81f311eae8ec91971b"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.29.1/agentbrowser-cli-darwin-x64"
        sha256 "180e3f243f56428a977707058032cd137d1e94579622633a2d8359a05f04d4e3"
      end
    end
    on_linux do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.29.1/agentbrowser-cli-linux-arm64"
        sha256 "ac427989a52bbd304819ea1450f915fa865a2fc725e07fdf6a3c8375136a9d61"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.29.1/agentbrowser-cli-linux-x64"
        sha256 "6d0aaf9d29c299a3862040c043ea27c9ac20d4eba9e21239708af7d8c2a86f7c"
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
