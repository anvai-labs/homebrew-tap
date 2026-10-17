class Proximadb < Formula
  desc "Vector, document, and graph database server"
  homepage "https://github.com/anvai-labs/proximaDB"
  url "https://github.com/anvai-labs/proximaDB/releases/download/v0.4.1/proximadb-0.4.1-x86_64-unknown-linux-gnu.tar.gz"
  sha256 "13ddc6628408fe8a88157b12fe53af4275a4c697460490ebe45b9c62b4510bc6"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on arch: :x86_64
  depends_on :linux
  depends_on "openssl@3"
  depends_on "xz"

  def install
    bin.install "proximadb-server", "proximadb-bench", "proximadb-migrate"
    pkgshare.install "config"
    prefix.install "README.adoc"
  end

  def caveats
    <<~EOS
      This upstream release supports Linux x86_64 only.
      Example configuration files are in #{pkgshare}/config.
      Copy and configure one before starting proximadb-server --config <path>.
      Installation does not start a server or modify an existing database.
      The embedded Python engine is a separate upstream distribution.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/proximadb-server --version")
    assert_match "Usage:", shell_output("#{bin}/proximadb-bench --help")
    assert_match "Usage:", shell_output("#{bin}/proximadb-migrate --help")
  end
end
