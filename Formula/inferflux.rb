# typed: false
# frozen_string_literal: true

class Inferflux < Formula
  desc "C++ LLM inference server (inferfluxd) and operator CLI (inferctl)"
  homepage "https://github.com/anvai-labs/inferflux"
  license "Apache-2.0"

  # Prebuilt cpack archives from inferflux's Release Packaging tag path
  # (macOS leg builds on arm64, Linux leg on x86_64). Versions are literal
  # so brew detects them from the URL; the Update Inferflux Formula
  # workflow rewrites them plus the sha256 lines.
  if OS.mac? && Hardware::CPU.arm64?
    url "https://github.com/anvai-labs/inferflux/releases/download/v0.1.0/inferflux-0.1.0-Darwin-arm64.tar.gz"
    sha256 "3729757f932e98ad0afee2f34a891d03cab334e1828a2dc6b44cf5a008f3a383"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/inferflux/releases/download/v0.1.0/inferflux-0.1.0-Linux-x86_64.tar.gz"
    sha256 "007edf053c5d31a49e08d5d73486ab74a29def87c689d74df759063cbfc55f16"
  end

  livecheck do
    url "https://github.com/anvai-labs/inferflux/releases/latest"
    strategy :header_match
    regex(%r{/tag/v?(\d+(?:\.\d+)+)$}i)
  end

  def install
    bin.install "inferfluxd", "inferctl"
    # Sample server config; hand to inferfluxd via --config or copy locally.
    (pkgetc/"inferflux").install "etc/inferflux/inferflux.yaml"
  end

  test do
    assert_predicate bin/"inferfluxd", :executable?
    # `inferctl status --help` prints usage and exits 1 outside a session.
    assert_match "Usage", shell_output("#{bin}/inferctl status --help", 1)
  end
end
