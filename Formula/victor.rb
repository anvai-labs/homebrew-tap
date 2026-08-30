# typed: false
# frozen_string_literal: true

class Victor < Formula
  include Language::Python::Virtualenv

  desc "Enterprise-Ready AI Coding Assistant - Any model, any provider"
  homepage "https://github.com/anvai-labs/victor"
  url "https://files.pythonhosted.org/packages/e1/4d/786bf9827f31ca6e186a6480306484006e5574573ae28f8eaad8ce9189a0/victor_ai-0.9.0.tar.gz"
  sha256 "d2e46ee357cb68cf86b87045f7acea4194f4cff54a99e4d5e1c141a37a7a99f2"
  license "Apache-2.0"

  depends_on "python@3.12"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "victor", shell_output("#{bin}/victor --version")
  end
end
