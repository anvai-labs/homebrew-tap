# typed: false
# frozen_string_literal: true

class Sentinelpass < Formula
  desc "Secure, local-first password manager with browser autofill"
  homepage "https://github.com/anvai-labs/sentinelpass"
  license "Apache-2.0"

  # Prebuilt release archives; aarch64-linux is not shipped upstream yet and
  # the tarballs are arch-unnamed (-macos is arm64-only). Versions are literal
  # so brew detects them from the URL.
  if OS.mac? && Hardware::CPU.arm64?
    url "https://github.com/anvai-labs/sentinelpass/releases/download/v0.9.0/sentinelpass-0.9.0-macos.tar.gz"
    sha256 "901d3f61847726dbab924976274af150d4106a6b873782d27025673e16b50828"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/sentinelpass/releases/download/v0.9.0/sentinelpass-0.9.0-linux.tar.gz"
    sha256 "9f8f4717103a3c1cd9840d2d9802da1bb8940e1c260318faaf71ddfe6e8ae421"
  end

  livecheck do
    url "https://github.com/anvai-labs/sentinelpass/releases/latest"
    strategy :header_match
    regex(%r{/tag/v?(\d+(?:\.\d+)+)$}i)
  end

  def install
    bin.install "sentinelpass"
    bin.install "sentinelpass-host"
    bin.install "sentinelpass-ui"
    if OS.linux?
      bin.install "sentinelpass-daemon"
    end
  end

  test do
    assert_match "sentinelpass", shell_output("#{bin}/sentinelpass --help")
  end
end
