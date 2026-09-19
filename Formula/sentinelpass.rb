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
    url "https://github.com/anvai-labs/sentinelpass/releases/download/v0.13.0/sentinelpass-0.13.0-macos.tar.gz"
    sha256 "6f7a52d28065c891366bda074a0b5e8ec1ed79e50e18c698905fdf63baee2d11"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/sentinelpass/releases/download/v0.13.0/sentinelpass-0.13.0-linux.tar.gz"
    sha256 "c65ffc7fd2f0ba87043f0efa694f3ccc309984bd578ac76bbd1709c1bd48ab91"
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
