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
    url "https://github.com/anvai-labs/sentinelpass/releases/download/v0.8.0/sentinelpass-0.8.0-macos.tar.gz"
    sha256 "13f6f9833eb0ffa1da312415ee7f209e15c8553a879dbb31cedbbbcccf394175"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/sentinelpass/releases/download/v0.8.0/sentinelpass-0.8.0-linux.tar.gz"
    sha256 "c0ff14fdb95368aabe7790e57b4b5a45b2bb34c773f2815820470471e23a156c"
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
