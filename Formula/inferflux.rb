# typed: false
# frozen_string_literal: true

class Inferflux < Formula
  desc "C++ LLM inference server (inferfluxd) and operator CLI (inferctl)"
  homepage "https://github.com/anvai-labs/inferflux"
  license "Apache-2.0"

  # Prebuilt cpack archives from inferflux's Release Packaging tag path
  # (macOS leg builds on arm64, Linux legs on x86_64 and native arm64).
  # Versions are literal so brew detects them from the URL; the Update
  # Inferflux Formula workflow rewrites them plus the sha256 lines.
  if OS.mac? && Hardware::CPU.arm64?
    url "https://github.com/anvai-labs/inferflux/releases/download/v0.2.0/inferflux-0.2.0-Darwin-arm64.tar.gz"
    sha256 "7daeb9957b0668a17acdc6e146a9583d4e43d3a8d7b12452819c5db3497baaf3"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/inferflux/releases/download/v0.2.0/inferflux-0.2.0-Linux-x86_64.tar.gz"
    sha256 "a05e683489bf52d512703e3743ea1bddede61adb3ccd9a69de1298ae748b5547"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/inferflux/releases/download/v0.2.0/inferflux-0.2.0-Linux-aarch64.tar.gz"
    sha256 "8c610c70b3c9628d3c957e4a376a9f1ac70157c5c3b9e0c6eeecb93771f6e33e"
  end

  livecheck do
    url "https://github.com/anvai-labs/inferflux/releases/latest"
    strategy :header_match
    regex(%r{/tag/v?(\d+(?:\.\d+)+)$}i)
  end

  # llama/ggml are statically linked into the release binaries
  # (BUILD_SHARED_LIBS=OFF in Release Packaging); these two stay dynamic
  # against Homebrew's kegs, which is what the release runners build against.
  depends_on "openssl@3"
  depends_on "yaml-cpp"

  def install
    # The cpack tgz is the staged install tree (bin/, etc/, share/); brew
    # strips the single version-named root dir, so paths are root-relative.
    bin.install "bin/inferfluxd", "bin/inferctl"
    # Sample server config; hand to inferfluxd via --config or copy locally.
    pkgetc.install "etc/inferflux/inferflux.yaml"
  end

  test do
    assert_predicate bin/"inferfluxd", :executable?
    # Top-level help prints the usage block and exits 1 (no session/server).
    assert_match "Usage", shell_output("#{bin}/inferctl --help", 1)
  end
end
