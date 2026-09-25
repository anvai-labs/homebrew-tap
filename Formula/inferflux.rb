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
    url "https://github.com/anvai-labs/inferflux/releases/download/v0.4.0/inferflux-0.4.0-Darwin-arm64.tar.gz"
    sha256 "63c9f3e099dad8180e80c22e86eaeabf0b2db512f96ec0f9035e835a29d3375c"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/inferflux/releases/download/v0.4.0/inferflux-0.4.0-Linux-x86_64.tar.gz"
    sha256 "4a1aca3c7bb63582fc18cbb406d9a850903776753b91ea6d5785038b4a975363"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/inferflux/releases/download/v0.4.0/inferflux-0.4.0-Linux-aarch64.tar.gz"
    sha256 "c66f31b9b5d5cf606c232be72d799aa0ef64ebdf25db9a6a4eda5fa1c06e00cb"
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
