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
    sha256 "75ed7b849114b862d6b2fe536d733b734a0ebd0f8af7970d070e2296189b2778"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/inferflux/releases/download/v0.1.0/inferflux-0.1.0-Linux-x86_64.tar.gz"
    sha256 "ac31f4312ecb93551d25b50832b1134929d4c650f0369f3cc3376e972c4deb3a"
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
    (pkgetc/"inferflux").install "etc/inferflux/inferflux.yaml"
  end

  test do
    assert_predicate bin/"inferfluxd", :executable?
    # `inferctl status --help` prints usage and exits 1 outside a session.
    assert_match "Usage", shell_output("#{bin}/inferctl status --help", 1)
  end
end
