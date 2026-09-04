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
    url "https://github.com/anvai-labs/sandhi/releases/download/v0.5.1/sandhi-proxy-v0.5.1-aarch64-apple-darwin.tar.gz"
    sha256 "8c17c7d229eb7ac5fd5b1d37aa9340f6f6d54d03da2fbe8f235b4d5d858f71bd"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/sandhi/releases/download/v0.5.1/sandhi-proxy-v0.5.1-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "29146aa3c923df30244bfd68eadad08879e33bb1802877738f9a7557d5a16e99"
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
