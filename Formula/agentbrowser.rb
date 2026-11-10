# typed: false
# frozen_string_literal: true

class Agentbrowser < Formula
  desc "Agent-native browser service for AI agents (server + CLI + MCP server)"
  homepage "https://github.com/anvai-labs/agentbrowser"
  license "Apache-2.0"
  # Same bottles as the tagged version; formula-only change (service-env
  # override file: the wrapper now merges ~/.config/agentbrowser/service.env
  # into the service environment at every start — see caveats).
  revision 3

  # Prebuilt release artifacts: the agentbrowser-mcp executable (raw
  # per-target binaries) and, since v1.6.1, the API server as per-target
  # "fat tarballs" (built dist/ + pruned production node_modules — Playwright
  # is bundler-hostile, so the tree ships intact; see upstream #17). The
  # windows exe is not installable via brew. Versions are literal so brew
  # detects them from the URL; the Update Agentbrowser Formula workflow
  # rewrites them plus the sha256 lines.
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.35.1/agentbrowser-mcp-darwin-arm64"
    sha256 "7d7f2ceb7459bc08498a0c85fdce0128394d56cce8b7114aeca49e12a166bbfd"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.35.1/agentbrowser-mcp-darwin-x64"
    sha256 "a32064109629616c914af882fb8e58ca181999b5d25edfafe4d18627c1b05e58"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.35.1/agentbrowser-mcp-linux-arm64"
    sha256 "971ff52e92120d4fe4298698cc3c36cb3d08f10c5b0cc72f7fac02e5222928db"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.35.1/agentbrowser-mcp-linux-x64"
    sha256 "d985dd4dbf22d1150895b6677add4289b9a25620f5e8654f65ce4ab321e7e750"
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
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.35.1/agentbrowser-server-darwin-arm64.tar.gz"
        sha256 "98e392e5b1eb2f61f9c0c53e41131b0e3cc9d386ece30b09b123c95e3e2c779c"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.35.1/agentbrowser-server-darwin-x64.tar.gz"
        sha256 "021552e9cbf045c56f1602abe157cb50d0c161e581d2ef7f4818caad5bf1889c"
      end
    end
    on_linux do
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.35.1/agentbrowser-server-linux-x64.tar.gz"
        sha256 "b6222e72ceeeb3ac12904ba5b7ca119807fbd12809025d313a8f0e08da95b83f"
      end
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.35.1/agentbrowser-server-linux-arm64.tar.gz"
        sha256 "5bd8c98ce293be5400fbd2dda798ff59b74ff1112d0284cb0c76179b4b9a9ed8"
      end
    end
  end

  resource "cli" do
    on_macos do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.35.1/agentbrowser-cli-darwin-arm64"
        sha256 "a776c970280427a52fa79b9f081920e1bc45ffb207da5af8c156054c74eaabb8"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.35.1/agentbrowser-cli-darwin-x64"
        sha256 "cbca32f16b5f582e587bccd49d907457a1b3a650f2ffbc97bfdb63093ce4a2bb"
      end
    end
    on_linux do
      on_arm do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.35.1/agentbrowser-cli-linux-arm64"
        sha256 "811b446649fc1dc2f8e1dce257b8d6df9080ad7b6466e9062e309c3313abd460"
      end
      on_intel do
        url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.35.1/agentbrowser-cli-linux-x64"
        sha256 "6d351b343b36fc9d6682e2405bc7b213227126235e556437bcd838916a9ef274"
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
    # merges the operator service-env override file, and sources the
    # deployment env file under etc before exec. Both files are read at
    # EVERY start (the wrapper is the service run command), so edits apply
    # on `brew services restart` — hand-editing the generated launchd plist
    # is never required, and brew never rewrites etc/ or the override file.
    node_bin = formula_opt_bin("node@24")/"node"
    (bin/"agentbrowser-server").write <<~EOS
      #!/bin/bash
      export PLAYWRIGHT_BROWSERS_PATH="${PLAYWRIGHT_BROWSERS_PATH:-#{var}/agentbrowser/browsers}"
      if ! compgen -G "$PLAYWRIGHT_BROWSERS_PATH/chromium*" >/dev/null 2>&1; then
        echo "agentbrowser-server: bootstrapping Chromium (one-time download)..." >&2
        PW_CLI="$(echo #{libexec}/node_modules/.pnpm/playwright@*/node_modules/playwright/cli.js)"
        "#{node_bin}" "$PW_CLI" install chromium 1>&2
      fi
      # Operator service-env override (ADR-034): simple KEY=VALUE lines,
      # parsed without shell sourcing. Owner-only perms are required; a
      # group/world-readable file is refused loudly and skipped (the plist
      # environment stays the base). Absent file: fail-open, no change.
      SERVICE_ENV_FILE="${HOME}/.config/agentbrowser/service.env"
      if [ -f "$SERVICE_ENV_FILE" ]; then
        perms="$(stat -c '%a' "$SERVICE_ENV_FILE" 2>/dev/null || stat -f '%Lp' "$SERVICE_ENV_FILE" 2>/dev/null)"
        if [ "$perms" = "600" ] || [ "$perms" = "400" ]; then
          while IFS= read -r line || [ -n "$line" ]; do
            line="${line%$'\\r'}"
            case "$line" in ""|"#"*) continue ;; esac
            key="${line%%=*}"
            [ "$key" = "$line" ] && continue
            key="${key#"${key%%[![:space:]]*}"}"; key="${key%"${key##*[![:space:]]}"}"
            case "$key" in ""|*[!A-Za-z0-9_]*|[0-9]*) continue ;; esac
            value="${line#*=}"
            value="${value#"${value%%[![:space:]]*}"}"; value="${value%"${value##*[![:space:]]}"}"
            export "$key=$value"
          done < "$SERVICE_ENV_FILE"
        else
          echo "agentbrowser-server: REFUSING $SERVICE_ENV_FILE — mode $perms is not owner-only; chmod 600 it (or remove it). The service keeps its base environment." >&2
        fi
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
    # HOST/PORT are deliberately NOT pinned here. The server defaults to
    # 127.0.0.1:5709 itself, and pinning them in the generated plist meant
    # brew's native user override (~/.homebrew/services/agentbrowser.env)
    # could never change the bind — the documented knob for exposing the
    # service. See caveats.
    # Policy-bearing env (MAX_RESPONSE_BYTES etc.) is deprecated and
    # cannot combine with a policy file; the document under etc is
    # the one durable home for policy configuration.
    environment_variables "AGENTBROWSER_POLICY_FILE" => "#{etc}/agentbrowser/policy.json"
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
      authenticate with AGENTBROWSER_API_KEY (keys configured as below).

      Binding: the service listens on 127.0.0.1:5709 by default. To expose
      it on all interfaces — never by editing the plist, which brew services
      regenerates from this formula on every start — add ONE line to brew's
      native override file and restart:

        printf 'HOST=0.0.0.0\n' >> ~/.homebrew/services/agentbrowser.env
        brew services restart anvai-labs/tap/agentbrowser

      (unquoted value: brew's parser does not strip quotes). The server
      (1.34.0+) refuses an unauthenticated bind beyond loopback, so configure
      AGENTBROWSER_API_KEYS first — in #{etc}/agentbrowser/env (the wrapper
      applies it last, so it WINS) or in the override file below. For keyless
      remote access keep loopback and tunnel instead:

        ssh -N -L 5709:127.0.0.1:5709 <user>@<this-host>

      Service environment overrides (ADR-034): the wrapper merges
      ~/.config/agentbrowser/service.env into the service environment at
      every START (not at install), so edits apply on
      `brew services restart` and survive plist regeneration — hand-editing
      the generated plist is never the way. The file holds simple KEY=VALUE
      lines (one per line; no "export", no shell sourcing; quotes are NOT
      stripped; blank lines and #-comments are ignored), e.g. the operator
      Chrome attachment pair:

        mkdir -p ~/.config/agentbrowser
        printf 'AGENTBROWSER_CDP_ENDPOINT=http://127.0.0.1:9222\n' >> ~/.config/agentbrowser/service.env
        printf 'AGENTBROWSER_CDP_ALLOW_UNENFORCED_EGRESS=true\n' >> ~/.config/agentbrowser/service.env
        printf 'AGENTBROWSER_CDP_PROFILE_HINT=<profile-basename>\n' >> ~/.config/agentbrowser/service.env
        chmod 600 ~/.config/agentbrowser/service.env
        brew services restart anvai-labs/tap/agentbrowser

      The file must be owner-only (chmod 600 or 400): a group/world-readable
      file is REFUSED with a loud line in the service error log and skipped
      (the plist environment stays the base). No file: no change. Keys must
      be valid shell names; anything else on the line is skipped. These
      values override the plist's environment and brew's native
      ~/.homebrew/services/agentbrowser.env override; #{etc}/agentbrowser/env
      is still applied last and wins over this file.

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
