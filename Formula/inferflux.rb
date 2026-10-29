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
    url "https://github.com/anvai-labs/inferflux/releases/download/v0.6.1/inferflux-0.6.1-Darwin-arm64.tar.gz"
    sha256 "e9e5d7238091172be1d01c65c4dd84c759892ca721bd7733c7bf8a37b53cb717"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/inferflux/releases/download/v0.6.1/inferflux-0.6.1-Linux-x86_64.tar.gz"
    sha256 "12db2ffd87f901a9342332a2a9e828a6a78ba4407aee400bef73d241bdc01d27"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/inferflux/releases/download/v0.6.1/inferflux-0.6.1-Linux-aarch64.tar.gz"
    sha256 "eac85df11fa16e9e42ceaab6cc57cefe726109ed3c28c3343230e8e291574af8"
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
