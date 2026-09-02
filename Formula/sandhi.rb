# typed: false
# frozen_string_literal: true

class Sandhi < Formula
  desc "AI usage gateway: meter, attribute, and budget every model call"
  homepage "https://github.com/anvai-labs/sandhi"
  license "Apache-2.0"

  # Prebuilt release archives. Intel macs are not shipped (the macos-13 runner
  # leg was never schedulable — see sandhi's release.yml) and aarch64-linux is
  # a follow-up; on unsupported platforms use sandhi's scripts/quickstart.sh to
  # build from source. Versions are literal so brew detects them from the URL;
  # the Update Sandhi Formula workflow rewrites them plus the sha256 lines.
  if OS.mac? && Hardware::CPU.arm64?
    url "https://github.com/anvai-labs/sandhi/releases/download/v0.5.0/sandhi-proxy-v0.5.0-aarch64-apple-darwin.tar.gz"
    sha256 "9e92774cd1b0a90262e6a9c39b5546f639f3c9e1be55443546ebf8c3b97ef218"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/sandhi/releases/download/v0.5.0/sandhi-proxy-v0.5.0-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "a34c2b414a2e5a86a46ae5d5c195418d909707d0a23335cce780bbe7529be3ab"
  end

  livecheck do
    url "https://github.com/anvai-labs/sandhi/releases/latest"
    strategy :header_match
    regex(%r{/tag/v?(\d+(?:\.\d+)+)$}i)
  end

  def install
    bin.install "sandhi-proxy", "sandhi"
  end

  service do
    run [opt_bin/"sandhi-proxy"]
    # `environment_variables`, not `environment` — Homebrew 6 renamed the DSL.
    environment_variables "SANDHI_BIND"  => "127.0.0.1:8787",
                          "SANDHI_STORE" => var/"sandhi/usage.db"

    keep_alive true
    log_path var/"log/sandhi-proxy.log"
    error_log_path var/"log/sandhi-proxy.err.log"
  end

  test do
    # sandhi-proxy is a server binary without a --help surface; assert the
    # installed artifact directly, and exercise the operator CLI's version.
    assert_predicate bin/"sandhi-proxy", :executable?
    assert_match version.to_s, shell_output("#{bin}/sandhi --version")
  end
end
