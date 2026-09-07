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
    url "https://github.com/anvai-labs/inferflux/releases/download/v0.1.1/inferflux-0.1.1-Darwin-arm64.tar.gz"
    sha256 "07c3852cf13439a782bd841b36cade7a2eed639ce5303893ff8b494fdfebe721"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/inferflux/releases/download/v0.1.1/inferflux-0.1.1-Linux-x86_64.tar.gz"
    sha256 "6665aa83146b4faf2535dfcbc0f0039f97a2c81bc452909ab26ed5691197022c"
  elsif OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/anvai-labs/inferflux/releases/download/v0.1.1/inferflux-0.1.1-Linux-aarch64.tar.gz"
    sha256 "3b3dbb3cfedb723a7fe0a7406368618cd6be61644a6e1b365c719ba5ba506554"
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
