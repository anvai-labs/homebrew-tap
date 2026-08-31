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
    url "https://github.com/anvai-labs/sandhi/releases/download/v0.2.0/sandhi-proxy-v0.2.0-aarch64-apple-darwin.tar.gz"
    sha256 "856990b78798dbca77cf7cc9a1c02ea98c43c74cba32fdb5bafb51dc23e1d804"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/sandhi/releases/download/v0.2.0/sandhi-proxy-v0.2.0-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "b664165361ff0bfb56db2690e94201eb5e4509083d5728e5f26939e7efa5f4c7"
  end

  livecheck do
    url "https://github.com/anvai-labs/sandhi/releases/latest"
    strategy :header_match
    regex(%r{/tag/v?(\d+(?:\.\d+)+)$}i)
  end

  def install
    bin.install "sandhi-proxy"
    # The `sandhi` operator CLI joins the archive from sandhi v0.2.1 (the CLI
    # was not packaged in release archives before then).
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
    # installed artifact directly. (The `sandhi` CLI gets a --version test once
    # it ships in the archive.)
    assert_predicate bin/"sandhi-proxy", :executable?
  end
end
