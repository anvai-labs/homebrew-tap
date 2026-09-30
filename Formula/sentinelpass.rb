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
    url "https://github.com/anvai-labs/sentinelpass/releases/download/v0.14.0/sentinelpass-0.14.0-macos.tar.gz"
    sha256 "5a872a88436a477d6368230e78b55203d1c6b82fe2a475dbf23a4a5b35a80ca5"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/sentinelpass/releases/download/v0.14.0/sentinelpass-0.14.0-linux.tar.gz"
    sha256 "2c52b9e33070d2daf1f35161e818940d3ea7ca7c31e0559bfc884d03a4bd3c43"
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
