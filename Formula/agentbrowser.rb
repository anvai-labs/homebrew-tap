# typed: false
# frozen_string_literal: true

class Agentbrowser < Formula
  desc "Agent-native browser service for AI agents (agentbrowser-mcp server)"
  homepage "https://github.com/anvai-labs/agentbrowser"
  license "Apache-2.0"

  # Prebuilt release binaries (raw per-target executables, plus a
  # sha256sums.txt in each release). The windows exe is not installable via
  # brew. Versions are literal so brew detects them from the URL; the Update
  # Agentbrowser Formula workflow rewrites them plus the four sha256 lines.
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.4.0/agentbrowser-mcp-darwin-arm64"
    sha256 "db0df7997653f145690a9be640e8754562fdce0f537e228a18fe0e3bc6d36c49"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.4.0/agentbrowser-mcp-darwin-x64"
    sha256 "8311b22b29a765a11df4316bc3d8a215b3819932d5da1ea6b70e710342c56fbe"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.4.0/agentbrowser-mcp-linux-arm64"
    sha256 "a2b6c1f47a434eadbbb1e036cf28abd476eb38869ffbcf61f50ba34b084cbabf"
  elsif OS.linux? && Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/agentbrowser/releases/download/v1.4.0/agentbrowser-mcp-linux-x64"
    sha256 "2c15df9a390a3a9856871f7c43f464f14bd154919c0ca9a63508a7670bff91e2"
  end

  livecheck do
    url "https://github.com/anvai-labs/agentbrowser/releases/latest"
    strategy :header_match
    regex(%r{/tag/v?(\d+(?:\.\d+)+)$}i)
  end

  def install
    target = if OS.mac?
      Hardware::CPU.arm? ? "agentbrowser-mcp-darwin-arm64" : "agentbrowser-mcp-darwin-x64"
    else
      Hardware::CPU.arm? ? "agentbrowser-mcp-linux-arm64" : "agentbrowser-mcp-linux-x64"
    end
    bin.install target => "agentbrowser-mcp"
  end

  def caveats
    <<~EOS
      agentbrowser-mcp is a stdio MCP server — spawn it directly, no args.

      Wire up an MCP client:

        Claude Code:
          claude mcp add agentbrowser -- #{opt_bin}/agentbrowser-mcp
        Claude Desktop (claude_desktop_config.json):
          {"mcpServers": {"agentbrowser": {"command": "#{opt_bin}/agentbrowser-mcp"}}}
        Codex (~/.codex/config.toml):
          [mcp_servers.agentbrowser]
          command = "#{opt_bin}/agentbrowser-mcp"

      The browser tools drive an AgentBrowser service (default
      http://localhost:3000; override with AGENTBROWSER_BASE_URL; authenticate
      with AGENTBROWSER_API_KEY). The service itself is not yet distributed
      via brew — run it from a repo checkout until it ships.
    EOS
  end

  test do
    # agentbrowser-mcp is a stdio MCP server: given an open stdin it starts
    # serving and never exits, so probe it with stdin closed.
    system "/bin/sh", "-c", %Q("#{bin}/agentbrowser-mcp" --help </dev/null)
  end
end
