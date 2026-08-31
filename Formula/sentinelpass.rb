# typed: false
# frozen_string_literal: true

class Sentinelpass < Formula
  desc "Secure, local-first password manager with browser autofill"
  homepage "https://github.com/anvai-labs/sentinelpass"
  version "0.7.0"
  license "Apache-2.0"

  # Prebuilt release archives. aarch64-linux is not shipped upstream yet.
  if OS.mac? && Hardware::CPU.arm64?
    url "https://github.com/anvai-labs/sentinelpass/releases/download/v#{version}/sentinelpass-#{version}-macos.tar.gz"
    sha256 "9b7af5893e08c943986feda4948426f454003151046e3c45c8bea4cfb15934c8"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/sentinelpass/releases/download/v#{version}/sentinelpass-#{version}-linux.tar.gz"
    sha256 "41059e11238d8e9227ffa24b09e7507dcaffbb5232c2913954af9dbc3a4759e4"
  end

  def install
    bin.install "sentinelpass"
    bin.install "sentinelpass-host"
    bin.install "sentinelpass-ui"
    on_linux do
      bin.install "sentinelpass-daemon"
    end
  end

  test do
    assert_match "sentinelpass", shell_output("#{bin}/sentinelpass --help")
  end
end
