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
    url "https://github.com/anvai-labs/sandhi/releases/download/v0.6.1/sandhi-proxy-v0.6.1-aarch64-apple-darwin.tar.gz"
    sha256 "ef8d74571b8e23f920ff3eb13b77d4709f0cd60c8f26796e7c310ea837f7ce87"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/sandhi/releases/download/v0.6.1/sandhi-proxy-v0.6.1-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "29f69993ef4c41f7d78f2ba8ea6d5aa57026dad1d6f94d0f87321cb95545b2f0"
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
