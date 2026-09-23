# typed: false
# frozen_string_literal: true

class Sandhi < Formula
  desc "AI usage gateway: meter, attribute, and budget every model call"
  homepage "https://github.com/anvai-labs/sandhi"
  license "Apache-2.0"

  # Prebuilt release archives. Intel macs are not shipped (the macos-13 runner
  # leg was never schedulable — see sandhi's release.yml) and aarch64-linux is
  # a follow-up; on unsupported platforms use sandhi's scripts/quickstart.sh to
  # build from source. Versions are literal so brew detects them from the URL;
  # the Update Sandhi Formula workflow rewrites them plus the sha256 lines.
  if OS.mac? && Hardware::CPU.arm64?
    url "https://github.com/anvai-labs/sandhi/releases/download/v0.9.0/sandhi-proxy-v0.9.0-aarch64-apple-darwin.tar.gz"
    sha256 "f3a4b363ab66209311d2f722b8cb79a0fd3a1fa24ac66f6c6141a30312269fd3"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/anvai-labs/sandhi/releases/download/v0.9.0/sandhi-proxy-v0.9.0-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "3cfe9f776dc543dc4d0285e8d92b4054825fbc76781fb8f3d2b6a70f5b30899c"
  end

  livecheck do
    url "https://github.com/anvai-labs/sandhi/releases/latest"
    strategy :header_match
    regex(%r{/tag/v?(\d+(?:\.\d+)+)$}i)
  end

  def install
    bin.install "sandhi-proxy", "sandhi"
  end

  service do
    run [opt_bin/"sandhi-proxy"]
    # `environment_variables`, not `environment` — Homebrew 6 renamed the DSL.
    environment_variables "SANDHI_BIND"        => "127.0.0.1:8787",
                          "SANDHI_STORE"       => var/"sandhi/usage.db",
                          "SANDHI_OIDC_CONFIG" => etc/"sandhi/oidc.json"

    keep_alive true
    log_path var/"log/sandhi-proxy.log"
    error_log_path var/"log/sandhi-proxy.err.log"
  end

  def caveats
    <<~EOS
      Sandhi defaults to OIDC SSO and requires identity configuration before startup.
      Before starting the service, create a private #{etc}/sandhi/oidc.json using:
        https://github.com/anvai-labs/sandhi/blob/main/docs/operator/oidc-sso.md
      Provider credentials and existing usage databases are not migrated automatically.
    EOS
  end

  test do
    assert_equal "sandhi #{version}\n", shell_output("#{bin}/sandhi --version")
    assert_equal "sandhi-proxy #{version}\n", shell_output("#{bin}/sandhi-proxy --version")
  end
end
