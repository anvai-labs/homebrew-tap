require "language/java"

class DqKernel < Formula
  include Language::Python::Virtualenv

  desc "Data-quality checks and machine-readable evidence for Spark pipelines"
  homepage "https://github.com/anvai-labs/dq-kernel"
  url "https://github.com/anvai-labs/dq-kernel/releases/download/v0.1.0/dq_kernel-0.1.0.tar.gz"
  sha256 "70a762f2f17242a577ea833f80a31e3c618b4bb07f7d137b80348e25b3672ba1"
  license "Apache-2.0"

  depends_on "openjdk@17"
  depends_on "python@3.12"

  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sonoma
  end
  on_linux do
    depends_on arch: :x86_64
  end

  livecheck do
    url :stable
    strategy :github_latest
  end

  # BEGIN GENERATED RESOURCES
  resource "certifi" do
    url "https://files.pythonhosted.org/packages/0b/a7/71ac2cff56fec219ed242bb11b8efb69fcc4bec75db06fb7bfe35de520e6/certifi-2026.7.22-py3-none-any.whl"
    sha256 "62f22742b58a1a33014a2b6b706588a8d7e2a88ae7bd1a6ebe8c992928483775"
  end

  resource "charset-normalizer" do
    url "https://files.pythonhosted.org/packages/fc/ad/d07d7862a62ffa6d79d68074d14823243dd235a77c45262acbf6adeb28bf/charset_normalizer-3.5.2-py3-none-any.whl"
    sha256 "b6b751274acb69d77b3323d6b7dbaa3c7fdfc1eb829b7eb61d262f32e1af9685"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/58/a2/bb081bab032533a855d44de1d56f8e8426114ff1ba5d1f07a438a0a654f8/idna-3.20-py3-none-any.whl"
    sha256 "ab7ae7122974553370f0bdb919e1a960b2cd1bc1ef0276416d896db81c14582c"
  end

  resource "numpy" do
    on_macos do
      url "https://files.pythonhosted.org/packages/ff/a9/bac826765e971d8e16e2064e9ac7525fd69b40ac17c905033a7f5442023f/numpy-2.5.4-cp312-cp312-macosx_11_0_arm64.whl"
      sha256 "b11e8fda06a7d69f15ebf542660b74466c2e51094800c1fb794f47ad4faeef17"
    end
    on_linux do
      url "https://files.pythonhosted.org/packages/43/a3/c799c62e19c337e6d3770b08e475887fb30ce8477d3c09efca6b2f0228a6/numpy-2.5.4-cp312-cp312-manylinux_2_27_x86_64.manylinux_2_28_x86_64.whl"
      sha256 "fbde6962867ee75b48b0ee29b2b9372ec5d617799dbaf38e82dc0596f2f7738a"
    end
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/63/34/ba1c580383c9eada3711951fef0795c80b829a078d72188184bcab9dd527/packaging-26.3-py3-none-any.whl"
    sha256 "d7193f7c8e4e93f444fde0262bf90af30e16fa0ad0ad44cb553c87339b23cd1c"
  end

  resource "pandas" do
    on_macos do
      url "https://files.pythonhosted.org/packages/18/8f/48907c7c707b61a8e5018c32e1a3f70623209bfb59020a2f6196159d3aa7/pandas-3.0.6-cp312-cp312-macosx_11_0_arm64.whl"
      sha256 "9dab635a549e58a053c7b0fa054dc0bd7be22f0ed9a720f4a85d5fb993276172"
    end
    on_linux do
      url "https://files.pythonhosted.org/packages/cb/67/0c0f18e38d7f2d2af8c24b3315bc4046e73bbdd4a5540405506671ad0c0d/pandas-3.0.6-cp312-cp312-manylinux_2_24_x86_64.manylinux_2_28_x86_64.whl"
      sha256 "0704044b676496b8350e023b09f174a26772456c974a2b11c36bebb558c9490d"
    end
  end

  resource "poetry-core" do
    url "https://files.pythonhosted.org/packages/b7/25/7ed0a2ea4fe12f7fd0394387b5debbcd6fdbd06e5ac9daab96ba11471da8/poetry_core-2.5.0-py3-none-any.whl"
    sha256 "98ee465b66f7e14bb9fbe68fb5e00d0cff184f036993ec94610ae4b5612f3add"
  end

  resource "py4j" do
    url "https://files.pythonhosted.org/packages/bd/db/ea0203e495be491c85af87b66e37acfd3bf756fd985f87e46fc5e3bf022c/py4j-0.10.9.9-py2.py3-none-any.whl"
    sha256 "c7c26e4158defb37b0bb124933163641a2ff6e3a3913f7811b0ddbe07ed61533"
  end

  resource "pydeequ" do
    url "https://files.pythonhosted.org/packages/59/91/742862cd683e17de293c2ce4b5cd433b555de15181be37d7e9fb9889243c/pydeequ-1.7.0-py3-none-any.whl"
    sha256 "022ef4f75bdd1a1d1089df6881c44011aa5340f10dd1c326871cece6b7f0923c"
  end

  resource "pyhocon" do
    url "https://files.pythonhosted.org/packages/25/d9/810f7d07989dbe565712869094d2d595bed2af7474e02bb210563cee17c1/pyhocon-0.3.63.tar.gz"
    sha256 "7c98db21453c0390c6cedc376576fee4e0a153da5f2201bc681cf886820f4a7c"
  end

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/38/bb/d215ee7c73b61497b28a5503f9f53523f294fcc936762b7caf90e0c1c2b5/pyparsing-3.3.3-py3-none-any.whl"
    sha256 "ece8c00a69cf01b45d0b1dedabb469c90d8caf996d4fda40f147627a122849a4"
  end

  resource "pyspark" do
    url "https://files.pythonhosted.org/packages/95/ce/81e53e729790556e3983e95de1a7d5df91a34adfcd34b5a5ab0e0c6e9b33/pyspark-3.5.9.tar.gz"
    sha256 "ea27adc39ddac9413b8951e45aa748cbed6c785971b81386efc41938f6243d93"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/ec/57/56b9bcc3c9c6a792fcbaf139543cee77261f3651ca9da0c93f5c1221264b/python_dateutil-2.9.0.post0-py2.py3-none-any.whl"
    sha256 "a8b2bc7bffae282281c8140a97d3aa9c14da0b136dfe83f850eea9a5f7470427"
  end

  resource "pyyaml" do
    on_macos do
      url "https://files.pythonhosted.org/packages/89/a0/6cf41a19a1f2f3feab0e9c0b74134aa2ce6849093d5517a0c550fe37a648/pyyaml-6.0.3-cp312-cp312-macosx_11_0_arm64.whl"
      sha256 "fc09d0aa354569bc501d4e787133afc08552722d3ab34836a80547331bb5d4a0"
    end
    on_linux do
      url "https://files.pythonhosted.org/packages/8b/9d/b3589d3877982d4f2329302ef98a8026e7f4443c765c46cfecc8858c6b4b/pyyaml-6.0.3-cp312-cp312-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
      sha256 "ba1cc08a7ccde2d2ec775841541641e4548226580ab850948cbfda66a1befcdc"
    end
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/a0/f4/c67b0b3f1b9245e8d266f0f112c500d50e5b4e83cb6f3b71b6528104182a/requests-2.34.2-py3-none-any.whl"
    sha256 "2a0d60c172f83ac6ab31e4554906c0f3b3588d37b5cb939b1c061f4907e278e0"
  end

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/95/9c/c510029fc6ef33a6275cd2c5d3cecd6613dfd6aa401d57c54f1c18852ccf/setuptools-84.0.0-py3-none-any.whl"
    sha256 "51a52592b3b99e102b609654876bd65f19f999935166d1352678931132b0c670"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/b7/ce/149a00dd41f10bc29e5921b496af8b574d8413afcd5e30dfa0ed46c2cc5e/six-1.17.0-py2.py3-none-any.whl"
    sha256 "4721f391ed90541fddacab5acf947aa0d3dc7d27b2e1e8eda2be8970586c3274"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/92/9d/c4e665119135114480843e7ab388fa94d8480650450e6f8e26b70d323a4c/urllib3-2.8.0-py3-none-any.whl"
    sha256 "0cf3cae568d36aa9576b28dfb35f11328f1cb974ca7647d9475ebb86c75ac6e3"
  end

  resource "wheel" do
    url "https://files.pythonhosted.org/packages/2e/29/69cfbb602cd91690c55d38ba9fe53e6a7e76a6fa647bf38f19c138d25449/wheel-0.48.0-py3-none-any.whl"
    sha256 "3217dcc807155e45db462d7ef2431f5ddda0d7273b700d05a67b271ceb1287ab"
  end
  # END GENERATED RESOURCES

  def install
    venv = virtualenv_create(libexec, "python3.12", system_site_packages: false)
    vendor = buildpath/"vendor"
    vendor.mkpath
    downloads = resources.to_h do |resource|
      cached = resource.cached_download
      destination = vendor/cached.basename.sub(/\A\h{64}--/, "")
      cp cached, destination
      [resource.name, destination]
    end
    # Install the pinned backends before either source-only dependency. Nothing
    # may contact PyPI or resolve a different dependency during brew install.
    ENV["PIP_NO_INDEX"] = "1"
    backends = %w[packaging setuptools wheel poetry-core]
    venv.pip_install downloads.values_at(*backends), build_isolation: false
    venv.pip_install downloads.reject { |name, _| backends.include?(name) }.values, build_isolation: false
    venv.pip_install buildpath, build_isolation: false
    system "python3.12", "-m", "pip", "--python=#{libexec}/bin/python", "check"
    bin.install libexec/"bin/dq-kernel", libexec/"bin/dq-validate"
    bin.env_script_all_files libexec/"bin", Language::Java.java_home_env("17").merge(SPARK_VERSION: "3.5")
  end

  def caveats
    <<~EOS
      Includes Spark #{resource("pyspark").version} and PyDeequ in an isolated Python 3.12 environment.
      Use file:///absolute/path/config.conf for local dq-kernel configurations.
      Optional cloud and Great Expectations integrations are not bundled.
      Deequ rules additionally require the matching upstream Deequ JVM artifact.
    EOS
  end

  test do
    ENV["JAVA_HOME"] = Language::Java.java_home("17")
    ENV["SPARK_VERSION"] = "3.5"
    ENV["SPARK_LOCAL_IP"] = "127.0.0.1"
    ENV["PYSPARK_PYTHON"] = (libexec/"bin/python").to_s
    assert_match "--report-json", shell_output("#{bin}/dq-kernel --help")
    (testpath/"rules.conf").write <<~HOCON
      dqframework {
        dqrules = [{engine = custom, checks = [{constraint = NoNegativeValues, level = Error}]}]
      }
    HOCON
    system bin/"dq-validate", testpath/"rules.conf"
    (testpath/"invalid.conf").write "dqframework { dqrules = [] }"
    assert_match '"valid": false', shell_output("#{bin}/dq-validate --format json #{testpath}/invalid.conf", 1)
    (testpath/"smoke.py").write <<~PYTHON
      from importlib.metadata import version
      import json
      import sys
      from pathlib import Path
      from pyspark.sql import SparkSession
      from dq.cli import main

      assert version("dq-kernel") == "#{version}"
      assert version("pyspark") == "#{resource("pyspark").version}"
      spark = (SparkSession.builder.master("local[1]").appName("brew-dq-kernel")
               .config("spark.ui.enabled", "false").getOrCreate())
      try:
          Path("cli.conf").write_text('''dqframework {
            dataframes { input = brew_input }
            dqrules = [{engine = custom, dataframes = [input],
              checks = [{constraint = NoNegativeValues, level = Error}]}]
          }''')
          for values, expected in [([(1,), (2,)], "passed"), ([(1,), (-2,)], "failed")]:
              df = spark.createDataFrame(values, "amount long")
              df.createOrReplaceTempView("brew_input")
              sys.argv = ["dq-kernel", Path("cli.conf").resolve().as_uri(),
                          "--spark-master", "local[1]", "--report-json", "report.json",
                          "--dataset-id", "brew-fixture", "--dataset-sha256", "0" * 64]
              assert main() == (0 if expected == "passed" else 1)
              report = json.loads(Path("report.json").read_text())
              assert report["schema_version"] == "dq-report/v1", report
              assert report["status"] == expected and report["summary"]["total"] > 0, report
              assert report["dataset"]["id"] == "brew-fixture", report
      finally:
          spark.stop()
    PYTHON
    system libexec/"bin/python", testpath/"smoke.py"
  end
end
