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
    url "https://github.com/anvai-labs/sandhi/releases/download/v0.2.1/sandhi-proxy-v0.2.1-aarch64-apple-darwin.tar.gz"
    sha256 "3ad77e2ae079cd20321abc0e6ae92f4b0e8c7c7f0de13fd726eb1bbb4592c28d"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/sandhi/releases/download/v0.2.1/sandhi-proxy-v0.2.1-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "6364ccaabbea08c4103d593733b2cecc8be1b17658052bb7624d8329c3e5a637"
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
