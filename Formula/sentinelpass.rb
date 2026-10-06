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
    url "https://github.com/anvai-labs/sentinelpass/releases/download/v0.17.0/sentinelpass-0.17.0-macos.tar.gz"
    sha256 "4afbcae5782988c518e03ba655689d68d380ce6f03a6c867d219393818d2f11f"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/sentinelpass/releases/download/v0.17.0/sentinelpass-0.17.0-linux.tar.gz"
    sha256 "64b38ea5ab656ffa9518b4e7db0b2c4cc6b6fb89a0a8d38f47c11f1ed195397d"
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
