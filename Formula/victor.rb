# typed: false
# frozen_string_literal: true

class Victor < Formula
  include Language::Python::Virtualenv

  desc "Enterprise-Ready AI Coding Assistant - Any model, any provider"
  homepage "https://github.com/anvai-labs/victor"
  url "https://files.pythonhosted.org/packages/e1/4d/786bf9827f31ca6e186a6480306484006e5574573ae28f8eaad8ce9189a0/victor_ai-0.9.0.tar.gz"
  sha256 "d2e46ee357cb68cf86b87045f7acea4194f4cff54a99e4d5e1c141a37a7a99f2"
  license "Apache-2.0"

  depends_on "libyaml"
  depends_on "python@3.12"
  uses_from_macos "libxml2"
  uses_from_macos "libxslt"

  # victor-ai installs from its audited PyPI sdist (the url/sha256 above; the
  # update workflow rewrites exactly those two lines). The rest of the closure
  # ships as pinned wheel resources: building the native deps (orjson,
  # pydantic-core, tiktoken, lxml, aiohttp, numpy, ...) from sdists would need
  # a Rust/C toolchain on every user machine. Regenerate with
  #   tools/gen-victor-resources.py  (see its header for the recipe)
  # after a major victor bump that moves its dependency constraints.
  # sandhi-gateway ships no macOS-intel wheel, so victor targets macOS arm64
  # and Linux x86_64, like the rest of this tap.

  # The pip-built extension modules keep @rpath install names and carry no
  # headerpad, so brew's keg dylib-ID rewrite fails on them; @rpath names are
  # already relocatable, so leave them be.
  preserve_rpath

  resource "aiofiles" do
    url "https://files.pythonhosted.org/packages/bc/8a/340a1555ae33d7354dbca4faa54948d76d89a27ceef032c8c3bc661d003e/aiofiles-25.1.0-py3-none-any.whl"
    sha256 "abe311e527c862958650f9438e859c1fa7568a141b22abcd015e120e86a85695"
  end

  resource "aiohappyeyeballs" do
    url "https://files.pythonhosted.org/packages/71/43/1947f06babed6b3f1d7f38b0c767f52df66bfb2bc10b468c4a7de9eceff2/aiohappyeyeballs-2.7.1-py3-none-any.whl"
    sha256 "9243213661e29250eb41368e5daa826fc017156c3b8a11440826b2e3ed376472"
  end

  resource "aiohttp" do
    on_macos do
      on_arm do
        url "https://files.pythonhosted.org/packages/18/d4/eb96299230e20acf2efae207cb8d69051f1f68e357e5ea5e479bf6fb097a/aiohttp-3.14.3-cp312-cp312-macosx_10_13_universal2.whl"
        sha256 "39aded8c7f3b935b54aab1d8d73c70ec0ee2d3ec3b943e0e86611bc150ba47f5"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/18/d4/eb96299230e20acf2efae207cb8d69051f1f68e357e5ea5e479bf6fb097a/aiohttp-3.14.3-cp312-cp312-macosx_10_13_universal2.whl"
        sha256 "39aded8c7f3b935b54aab1d8d73c70ec0ee2d3ec3b943e0e86611bc150ba47f5"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/52/b7/7cd31f29d6055bd711ae6e669367fba6f5ae9de463910a793e30556a8db7/aiohttp-3.14.3-cp312-cp312-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "543906c127fb1d929b95076db19b83fa2d46751006ff1e23b093aa5ac4d8db42"
      end
    end
  end

  resource "aiosignal" do
    url "https://files.pythonhosted.org/packages/fb/76/641ae371508676492379f16e2fa48f4e2c11741bd63c48be4b12a6b09cba/aiosignal-1.4.0-py3-none-any.whl"
    sha256 "053243f8b92b990551949e63930a839ff0cf0b0ebbe0597b0f3fb19e1a0fe82e"
  end

  resource "annotated-doc" do
    url "https://files.pythonhosted.org/packages/3e/30/e900b21425a860e195f32e37657aa1f7c7f2b1bfb26f03ca209b90933c06/annotated_doc-0.0.5-py3-none-any.whl"
    sha256 "117bac03a25ede5df5440e855b32d556049ca169ead221505badf432fed4b101"
  end

  resource "annotated-types" do
    url "https://files.pythonhosted.org/packages/99/91/8acff4f5e50511b911bbccb72b8628a49c68ce14148cd9f6431094859a90/annotated_types-0.8.0-py3-none-any.whl"
    sha256 "f072f4d804ea359e4eaf198b1af7a8b0943881a87f31bb764f8bf219bb9419e0"
  end

  resource "anthropic" do
    url "https://files.pythonhosted.org/packages/ed/78/3f8b52708b03309e511990700bb8d0ec7a0c9db3d2a1e0d1c3ca417a4604/anthropic-1.2.0-py3-none-any.whl"
    sha256 "b60642b3e3cd6b8e3e328a2d3f2863ad2b6e743f1037e42cc0143f7df99f63c6"
  end

  resource "anyio" do
    url "https://files.pythonhosted.org/packages/da/35/f2287558c17e29fafc8ef3daf819bb9834061cfa43bff8014f7df7f63bdc/anyio-4.14.2-py3-none-any.whl"
    sha256 "9f505dda5ac9f0c8309b5e8bd445a8c2bf7246f3ce950121e45ea15bc41d1494"
  end

  resource "attrs" do
    url "https://files.pythonhosted.org/packages/64/b4/17d4b0b2a2dc85a6df63d1157e028ed19f90d4cd97c36717afef2bc2f395/attrs-26.1.0-py3-none-any.whl"
    sha256 "c647aa4a12dfbad9333ca4e71fe62ddc36f4e63b2d260a37a8b83d2f043ac309"
  end

  resource "beautifulsoup4" do
    url "https://files.pythonhosted.org/packages/88/c6/92fcd42f1ba33e1184263f25bfabf3d27c383410470f169e4b8163bf9c17/beautifulsoup4-4.15.0-py3-none-any.whl"
    sha256 "d6f88de62e1d4e38ecb1077eb9724cd0eff29d2a08ca16a401e9b9e93f117cf9"
  end

  resource "cachetools" do
    url "https://files.pythonhosted.org/packages/e4/d8/767faeda872075724b95dd675466a645f1b92aadcdcf2d1429dcfd76c176/cachetools-7.1.7-py3-none-any.whl"
    sha256 "ef98ef375ad188819ef2f9b3645e3987f4b8c5b7550e436ad998c2de78296df0"
  end

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/0b/a7/71ac2cff56fec219ed242bb11b8efb69fcc4bec75db06fb7bfe35de520e6/certifi-2026.7.22-py3-none-any.whl"
    sha256 "62f22742b58a1a33014a2b6b706588a8d7e2a88ae7bd1a6ebe8c992928483775"
  end

  resource "charset-normalizer" do
    url "https://files.pythonhosted.org/packages/cc/61/d01fc49b8dea277640b55a9e15960dbca9fdc8c9fde18e572d39c59f4019/charset_normalizer-3.5.1-py3-none-any.whl"
    sha256 "6df0ec430f9a831772c23ca5a224cba36517a58a84bb32c32bb59a9fa67c47f6"
  end

  resource "click" do
    url "https://files.pythonhosted.org/packages/58/50/6c0d534c5f134586a8e1ba4e330569e32f057e33372ae556463212fb4cd3/click-8.5.0-py3-none-any.whl"
    sha256 "255bc9599cf7748b4b1a446ccc735421bd08a2ae529a8b88597d3de5664ee360"
  end

  resource "diskcache" do
    url "https://files.pythonhosted.org/packages/3f/27/4570e78fc0bf5ea0ca45eb1de3818a23787af9b390c0b0a0033a1b8236f9/diskcache-5.6.3-py3-none-any.whl"
    sha256 "5e31b2d5fbad117cc363ebaf6b689474db18a1f6438bc82358b024abd4c2ca19"
  end

  resource "docstring-parser" do
    url "https://files.pythonhosted.org/packages/a7/5f/ed01f9a3cdffbd5a008556fc7b2a08ddb1cc6ace7effa7340604b1d16699/docstring_parser-0.18.0-py3-none-any.whl"
    sha256 "b3fcbed555c47d8479be0796ef7e19c2670d428d72e96da63f3a40122860374b"
  end

  resource "frozenlist" do
    url "https://files.pythonhosted.org/packages/9a/9a/e35b4a917281c0b8419d4207f4334c8e8c5dbf4f3f5f9ada73958d937dcc/frozenlist-1.8.0-py3-none-any.whl"
    sha256 "0c18a16eab41e82c295618a77502e17b195883241c563b00f0aa5106fc4eaa0d"
  end

  resource "gitdb" do
    url "https://files.pythonhosted.org/packages/a0/61/5c78b91c3143ed5c14207f463aecfc8f9dbb5092fb2869baf37c273b2705/gitdb-4.0.12-py3-none-any.whl"
    sha256 "67073e15955400952c6565cc3e707c554a4eea2e428946f7a4c162fab9bd9bcf"
  end

  resource "gitpython" do
    url "https://files.pythonhosted.org/packages/6f/5e/49cc172da4d0578644ba37cec5cb365b1fefc603b26edea9bcac1c7f830a/gitpython-3.1.61-py3-none-any.whl"
    sha256 "8ab28c9da863cdd9e7d7694ec46cf3e6c9a12d8a30a1acd3447aec11975d530c"
  end

  resource "h11" do
    url "https://files.pythonhosted.org/packages/04/4b/29cac41a4d98d144bf5f6d33995617b185d14b22401f75ca86f384e87ff1/h11-0.16.0-py3-none-any.whl"
    sha256 "63cf8bbe7522de3bf65932fda1d9c2772064ffb3dae62d55932da54b31cb6c86"
  end

  resource "httpcore" do
    url "https://files.pythonhosted.org/packages/7e/f5/f66802a942d491edb555dd61e3a9961140fd64c90bce1eafd741609d334d/httpcore-1.0.9-py3-none-any.whl"
    sha256 "2d400746a40668fc9dec9810239072b40b4484b640a8c38fd654a024c7a1bf55"
  end

  resource "httpcore2" do
    url "https://files.pythonhosted.org/packages/d2/74/d370e55600d9bcfa0d9794b0166126d49291a3d2b20c268fc98c453a4948/httpcore2-2.12.0-py3-none-any.whl"
    sha256 "7e04258ce01013d7d615e5b910a3b27fac937d7a95038227e79652b4ba3b4ceb"
  end

  resource "httpx" do
    url "https://files.pythonhosted.org/packages/2a/39/e50c7c3a983047577ee07d2a9e53faf5a69493943ec3f6a384bdc792deb2/httpx-0.28.1-py3-none-any.whl"
    sha256 "d909fcccc110f8c7faf814ca82a9a4d816bc5a6dbfea25d6591d6985b8ba59ad"
  end

  resource "httpx2" do
    url "https://files.pythonhosted.org/packages/c8/95/411ba65569158e862368917aaf56597f3e5fa3b91b0502919638465a08f3/httpx2-2.12.0-py3-none-any.whl"
    sha256 "cc8b6eecb8661c146b8f89a60e97456ee086e91a784ed31ac450c3a9e613dd36"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/57/b0/0e52c878c53f245edd3a11020f20979b3f490f245af532c7cae3027754b5/idna-3.19-py3-none-any.whl"
    sha256 "815e7be7a7806d54abb586dc943addc79e8b2ee16915059658cbeff4b1b43bf4"
  end

  resource "jiter" do
    on_macos do
      on_arm do
        url "https://files.pythonhosted.org/packages/94/2e/34957c2c1b661c252ba9bcc60ae0bddc27e0f7202c6073326a13c5390eec/jiter-0.16.0-cp312-cp312-macosx_11_0_arm64.whl"
        sha256 "5af7780e4a26bd7d0d989592bf9ef12ebf806b74ab709223ecca37c749872ea9"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/83/2b/52ace16ed031354f0539749a49e4bf33797d82bea5137910835fa4b09793/jiter-0.16.0-cp312-cp312-macosx_10_12_x86_64.whl"
        sha256 "67c3bc1760f8c99d805dcab4e644027142a53b1d5d861f18780ebdbd5d40b72a"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/a8/d2/4839422241aa12860ce597b20068727094ba0bc480723c74924ca5bad483/jiter-0.16.0-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "46add52f4ad47a08bfb1219f3e673da972191489a33016edefdb5ea55bfa8c48"
      end
    end
  end

  resource "jsonschema" do
    url "https://files.pythonhosted.org/packages/69/90/f63fb5873511e014207a475e2bb4e8b2e570d655b00ac19a9a0ca0a385ee/jsonschema-4.26.0-py3-none-any.whl"
    sha256 "d489f15263b8d200f8387e64b4c3a75f06629559fb73deb8fdfb525f2dab50ce"
  end

  resource "jsonschema-specifications" do
    url "https://files.pythonhosted.org/packages/41/45/1a4ed80516f02155c51f51e8cedb3c1902296743db0bbc66608a0db2814f/jsonschema_specifications-2025.9.1-py3-none-any.whl"
    sha256 "98802fee3a11ee76ecaca44429fda8a41bff98b00a0f2838151b113f210cc6fe"
  end

  resource "linkify-it-py" do
    url "https://files.pythonhosted.org/packages/13/d4/1152d1c7ab42d8b908be64fd200ddc870dc9d4925e951198702084aa1a7d/linkify_it_py-2.2.0-py3-none-any.whl"
    sha256 "3adc40eb5af300b2605fcfdb968c24e1d780a90f1f2221af7c15e5111e94d443"
  end

  resource "lxml" do
    on_macos do
      on_arm do
        url "https://files.pythonhosted.org/packages/ee/a4/55eb54507073089ab27743c5da2113c84f0d0b1715b33175fdd943c9652d/lxml-6.1.2-cp312-cp312-macosx_10_13_universal2.whl"
        sha256 "7d506bdba580ecb1a6ad2e2b5c49445e66d3e1f95894885739094393a1aad237"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/ee/a4/55eb54507073089ab27743c5da2113c84f0d0b1715b33175fdd943c9652d/lxml-6.1.2-cp312-cp312-macosx_10_13_universal2.whl"
        sha256 "7d506bdba580ecb1a6ad2e2b5c49445e66d3e1f95894885739094393a1aad237"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/de/e5/ce3e885264fdd0bdcb6b49c1ea1842f94281b39e4ff956099e8d57532c60/lxml-6.1.2-cp312-cp312-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
        sha256 "9477e14217c212e6023c994a71a1a349db19b0e10fd5bf189666b281ae63b1fd"
      end
    end
  end

  resource "markdown-it-py" do
    url "https://files.pythonhosted.org/packages/b3/81/4da04ced5a082363ecfa159c010d200ecbd959ae410c10c0264a38cac0f5/markdown_it_py-4.2.0-py3-none-any.whl"
    sha256 "9f7ebbcd14fe59494226453aed97c1070d83f8d24b6fc3a3bcf9a38092641c4a"
  end

  resource "mdit-py-plugins" do
    url "https://files.pythonhosted.org/packages/a5/69/6da5581c6a7fede7dc261bf4e67d6adca4196f176b43288b55b3db395b6e/mdit_py_plugins-0.6.1-py3-none-any.whl"
    sha256 "214c82fb2ac524472ab6a5bcab1de80f73b50443e187f401bfd77efbc7c6481d"
  end

  resource "mdurl" do
    url "https://files.pythonhosted.org/packages/b3/38/89ba8ad64ae25be8de66a6d463314cf1eb366222074cfda9ee839c56a4b4/mdurl-0.1.2-py3-none-any.whl"
    sha256 "84008a41e51615a49fc9966191ff91509e3c40b939176e643fd50a5c2196b8f8"
  end

  resource "multidict" do
    url "https://files.pythonhosted.org/packages/81/08/7036c080d7117f28a4af526d794aab6a84463126db031b007717c1a6676e/multidict-6.7.1-py3-none-any.whl"
    sha256 "55d97cc6dae627efa6a6e548885712d4864b81110ac76fa4e534c03819fa4a56"
  end

  resource "numpy" do
    on_macos do
      on_arm do
        url "https://files.pythonhosted.org/packages/66/ee/560deadcdde6c2f90200450d5938f63a34b37e27ebff162810f716f6a230/numpy-2.2.6-cp312-cp312-macosx_11_0_arm64.whl"
        sha256 "de749064336d37e340f640b05f24e9e3dd678c57318c7289d222a8a2f543e90c"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/82/5d/c00588b6cf18e1da539b45d3598d3557084990dcc4331960c15ee776ee41/numpy-2.2.6-cp312-cp312-macosx_10_13_x86_64.whl"
        sha256 "41c5a21f4a04fa86436124d388f6ed60a9343a6f767fced1a8a71c3fbca038ff"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/8c/3d/1e1db36cfd41f895d266b103df00ca5b3cbe965184df824dec5c08c6b803/numpy-2.2.6-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "fd83c01228a688733f1ded5201c678f0c53ecc1006ffbc404db9f7a899ac6249"
      end
    end
  end

  resource "openai" do
    url "https://files.pythonhosted.org/packages/a1/94/805b87ecc951c49ec8f247f5e8eb324ab064bd2ad73b6a0e704dd49aa073/openai-3.6.0-py3-none-any.whl"
    sha256 "508e2158bf971687f953b62e44b02f207792c815aac306816386d7ba34d37f5f"
  end

  resource "orjson" do
    on_macos do
      on_arm do
        url "https://files.pythonhosted.org/packages/be/4a/295da39c651c2faac8bd351a2a346f0fdedd9d50b847ee9dfc27d2207ef6/orjson-3.12.0-cp312-cp312-macosx_10_15_x86_64.macosx_11_0_arm64.macosx_10_15_universal2.whl"
        sha256 "aa3e43a6846e91d7bde3d5a9c66090fcd8744f569a9b6cffc5e1ca38f6a461c0"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/be/4a/295da39c651c2faac8bd351a2a346f0fdedd9d50b847ee9dfc27d2207ef6/orjson-3.12.0-cp312-cp312-macosx_10_15_x86_64.macosx_11_0_arm64.macosx_10_15_universal2.whl"
        sha256 "aa3e43a6846e91d7bde3d5a9c66090fcd8744f569a9b6cffc5e1ca38f6a461c0"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/8c/57/80b986ebfecd9c6a177ddf1c2319717f0cd8feffb2b78946595a18a2fc88/orjson-3.12.0-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "1192a7021b6d071aaf909864f6e924d6a2675ca360485b972b8401749311750b"
      end
    end
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/63/34/ba1c580383c9eada3711951fef0795c80b829a078d72188184bcab9dd527/packaging-26.3-py3-none-any.whl"
    sha256 "d7193f7c8e4e93f444fde0262bf90af30e16fa0ad0ad44cb553c87339b23cd1c"
  end

  resource "platformdirs" do
    url "https://files.pythonhosted.org/packages/c7/12/6f3fcd5067a9cbf4f8664b32957973498da8b083455203c8d9cab83a725c/platformdirs-4.11.5-py3-none-any.whl"
    sha256 "89f8d42695853b89c7170bd49bc3dc593f98a71e695ede88e06a3b247bc4563b"
  end

  resource "prompt-toolkit" do
    url "https://files.pythonhosted.org/packages/54/6f/84908cad2d6aa5144abcf7b42709fe4fdb459bc640ec7ac5786e7693dabc/prompt_toolkit-3.0.53-py3-none-any.whl"
    sha256 "01c0891d7f9237d5e339f7d3e42cdae80b7534abb1c7c0e3352efba6231492f2"
  end

  resource "propcache" do
    url "https://files.pythonhosted.org/packages/3a/ed/1cdcab6ba3d6ab7feca11fc14f0eeea80755bb53ef4e892079f31b10a25f/propcache-0.5.2-py3-none-any.whl"
    sha256 "be1ddfcbb376e3de5d2e2db1d58d6d67463e6b4f9f040c000de8e300295465fe"
  end

  resource "psutil" do
    on_macos do
      on_arm do
        url "https://files.pythonhosted.org/packages/80/c4/f5af4c1ca8c1eeb2e92ccca14ce8effdeec651d5ab6053c589b074eda6e1/psutil-7.2.2-cp36-abi3-macosx_11_0_arm64.whl"
        sha256 "1a7b04c10f32cc88ab39cbf606e117fd74721c831c98a27dc04578deb0c16979"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/e7/36/5ee6e05c9bd427237b11b3937ad82bb8ad2752d72c6969314590dd0c2f6e/psutil-7.2.2-cp36-abi3-macosx_10_9_x86_64.whl"
        sha256 "ed0cace939114f62738d808fdcecd4c869222507e266e574799e9c0faa17d486"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/b5/70/5d8df3b09e25bce090399cf48e452d25c935ab72dad19406c77f4e828045/psutil-7.2.2-cp36-abi3-manylinux2010_x86_64.manylinux_2_12_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "076a2d2f923fd4821644f5ba89f059523da90dc9014e85f8e45a5774ca5bc6f9"
      end
    end
  end

  resource "pydantic" do
    url "https://files.pythonhosted.org/packages/eb/47/c95ffc2009878c7aac0c5e08528022dcb885933252a88b5f170058014464/pydantic-2.13.5-py3-none-any.whl"
    sha256 "346a034f080da3755d8e9cb5e00e8b07de1d39e4f6e2c87d8ab7cafa0b269a73"
  end

  resource "pydantic-core" do
    on_macos do
      on_arm do
        url "https://files.pythonhosted.org/packages/db/50/26b091836076ce4cb2fac264186936acc069e0595772cfd02a563bc4761a/pydantic_core-2.46.5-cp312-cp312-macosx_11_0_arm64.whl"
        sha256 "a39ac25a9a2fa4072efdb429833c4a4c8009a51ff9eea3eeae131713cd27991e"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/82/3f/76358795aa7a8c6d4f36e2cb828ad1c90ee118e1393a9281664f5aade9d4/pydantic_core-2.46.5-cp312-cp312-macosx_10_12_x86_64.whl"
        sha256 "b9fe6fb92520e3fd61f2e49000b6911b188824f089b75973ea06d6267f0b476d"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/c0/a4/eb9409ec0736e50aa70a412f16c204ed149516846912f7e6724d4c73ee53/pydantic_core-2.46.5-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "0fc5be0abd4a407e200d844b404e33639a554e7bd0d448e7b9ae181be4789ac2"
      end
    end
  end

  resource "pydantic-settings" do
    url "https://files.pythonhosted.org/packages/30/a4/2bffa9f8e804325a09867f0e9d30795c80ea9f8d62560bd1b6ad6220eb2f/pydantic_settings-2.15.0-py3-none-any.whl"
    sha256 "0ba092c291c94baceb5eff768aa0d56400a457585bc0175925a5a5510303da42"
  end

  resource "pygments" do
    url "https://files.pythonhosted.org/packages/71/46/17f022dd3e953bf20a04a028a21ec746d942f8d2af30fa0f124fa0e6a684/pygments-2.21.0-py3-none-any.whl"
    sha256 "2363c69b61c4a97c838da3b130dcd6468f4848992b21a82f2a63ec34377137d9"
  end

  resource "python-dotenv" do
    url "https://files.pythonhosted.org/packages/0d/17/c5c6b53ddc18f297992099b3d9ec16c855c0ccc83263a21fe4d1c625ec6c/python_dotenv-1.2.3-py3-none-any.whl"
    sha256 "904552145e8bfed22162c09dab1c2b9b54fefa7b23ba780f4f26ca0316b0f0d9"
  end

  resource "pyyaml" do
    on_macos do
      on_arm do
        url "https://files.pythonhosted.org/packages/89/a0/6cf41a19a1f2f3feab0e9c0b74134aa2ce6849093d5517a0c550fe37a648/pyyaml-6.0.3-cp312-cp312-macosx_11_0_arm64.whl"
        sha256 "fc09d0aa354569bc501d4e787133afc08552722d3ab34836a80547331bb5d4a0"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/d1/33/422b98d2195232ca1826284a76852ad5a86fe23e31b009c9886b2d0fb8b2/pyyaml-6.0.3-cp312-cp312-macosx_10_13_x86_64.whl"
        sha256 "7f047e29dcae44602496db43be01ad42fc6f1cc0d8cd6c83d342306c32270196"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/8b/9d/b3589d3877982d4f2329302ef98a8026e7f4443c765c46cfecc8858c6b4b/pyyaml-6.0.3-cp312-cp312-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "ba1cc08a7ccde2d2ec775841541641e4548226580ab850948cbfda66a1befcdc"
      end
    end
  end

  resource "referencing" do
    url "https://files.pythonhosted.org/packages/2c/58/ca301544e1fa93ed4f80d724bf5b194f6e4b945841c5bfd555878eea9fcb/referencing-0.37.0-py3-none-any.whl"
    sha256 "381329a9f99628c9069361716891d34ad94af76e461dcb0335825aecc7692231"
  end

  resource "regex" do
    on_macos do
      on_arm do
        url "https://files.pythonhosted.org/packages/34/39/d939bd3a78c5b64e355067712a9b9ba0691ef1aab6526e9094f728369778/regex-2026.8.31-cp312-cp312-macosx_10_13_universal2.whl"
        sha256 "a1c9cd392daa08d3a3d5b663443a08071f4efbc1476f902142d51a229c60e852"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/34/39/d939bd3a78c5b64e355067712a9b9ba0691ef1aab6526e9094f728369778/regex-2026.8.31-cp312-cp312-macosx_10_13_universal2.whl"
        sha256 "a1c9cd392daa08d3a3d5b663443a08071f4efbc1476f902142d51a229c60e852"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/ea/83/7f51ce519cab3f44e026122afed7fb27f9cd06e37eeff421888cbf88e50a/regex-2026.8.31-cp312-cp312-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "9fe2540d8da1bbf12f7c1b909a9ae47c2b343fa2a2084280c21ead1c9fb0e6f7"
      end
    end
  end

  resource "requests" do
    url "https://files.pythonhosted.org/packages/a0/f4/c67b0b3f1b9245e8d266f0f112c500d50e5b4e83cb6f3b71b6528104182a/requests-2.34.2-py3-none-any.whl"
    sha256 "2a0d60c172f83ac6ab31e4554906c0f3b3588d37b5cb939b1c061f4907e278e0"
  end

  resource "rich" do
    url "https://files.pythonhosted.org/packages/82/3b/64d4899d73f91ba49a8c18a8ff3f0ea8f1c1d75481760df8c68ef5235bf5/rich-15.0.0-py3-none-any.whl"
    sha256 "33bd4ef74232fb73fe9279a257718407f169c09b78a87ad3d296f548e27de0bb"
  end

  resource "rpds-py" do
    on_macos do
      on_arm do
        url "https://files.pythonhosted.org/packages/a4/73/319dfa745dd668efe89309141ded489126461fcecd2b8f3a3cda185129b6/rpds_py-2026.6.3-cp312-cp312-macosx_11_0_arm64.whl"
        sha256 "538949e262e46caa31ac01bdb3c1e8f642622922cacbabbae6a8445d9dc33eaf"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/5c/be/2e8974163072e7bab7df1a5acd54c4498e75e35d6d18b864d3a9d5dadc92/rpds_py-2026.6.3-cp312-cp312-macosx_10_12_x86_64.whl"
        sha256 "a0811d33247c3d6128a3001d763f2aa056bb3425204335400ac54f89eec3a0d0"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/04/8f/d2f3f532616be4d06c316ef119683e832bd3d41e112bf3a88f4151c95b17/rpds_py-2026.6.3-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "ecabd69db66de867690f9797f2f8fa27ba501bbc24540cbdbdc649cd15888ba6"
      end
    end
  end

  resource "sandhi-gateway" do
    on_macos do
      on_arm do
        url "https://files.pythonhosted.org/packages/ad/88/29264ba615dc3fcc54284ad4c212f73a948d9a13f1cd1f8bb777fef63594/sandhi_gateway-0.1.6-cp311-abi3-macosx_11_0_arm64.whl"
        sha256 "7618bd4acdaabc7b1edfc1b515cff250101eb4420fc236f16c08f5d13dec50af"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/15/e5/a198edfea5f147b85a8d4c6da369392d51da9f9068975c9f0c268410a89b/sandhi_gateway-0.1.6-cp311-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "53d3dcf30d14b77515414dff41f487e82b7376ad9b6e0e6ab18b8303172d9239"
      end
    end
  end

  resource "shellingham" do
    url "https://files.pythonhosted.org/packages/e0/f9/0595336914c5619e5f28a1fb793285925a8cd4b432c9da0a987836c7f822/shellingham-1.5.4-py2.py3-none-any.whl"
    sha256 "7ecfff8f2fd72616f7481040475a65b2bf8af90a56c89140852d1120324e8686"
  end

  resource "smmap" do
    url "https://files.pythonhosted.org/packages/c1/d4/59e74daffcb57a07668852eeeb6035af9f32cbfd7a1d2511f17d2fe6a738/smmap-5.0.3-py3-none-any.whl"
    sha256 "c106e05d5a61449cf6ba9a1e650227ecfb141590d2a98412103ff35d89fc7b2f"
  end

  resource "sniffio" do
    url "https://files.pythonhosted.org/packages/e9/44/75a9c9421471a6c4805dbf2356f7c181a29c1879239abab1ea2cc8f38b40/sniffio-1.3.1-py3-none-any.whl"
    sha256 "2f6da418d1f1e0fddd844478f41680e794e6051915791a034ff65e5f100525a2"
  end

  resource "soupsieve" do
    url "https://files.pythonhosted.org/packages/eb/dc/ad025c1ee131eba60c69f4dd5779b18fcf1e6b21a343e2162a84d5d133c7/soupsieve-2.9.2-py3-none-any.whl"
    sha256 "8089a26fd974ca7a1f30276d3d8492ab266ab15af581642dfe8aa162e0c1c823"
  end

  resource "textual" do
    url "https://files.pythonhosted.org/packages/fb/be/35261223d9416a0751cdff1c7b4a6f881387218a12d439fe22fefebc8c04/textual-8.2.8-py3-none-any.whl"
    sha256 "267375fd402dc8d981457212efa71f0e3365fd17bba144ba9bb3ed7563cb374a"
  end

  resource "tiktoken" do
    on_macos do
      on_arm do
        url "https://files.pythonhosted.org/packages/69/9f/fe6b1aca23331aa5271df5a4bd07bf68a7059254d47faee1b8272592a777/tiktoken-0.14.0-cp312-cp312-macosx_11_0_arm64.whl"
        sha256 "d6cebe67765569df3dafac8474e4eccf5c19d24140492567a5e58a11445732a4"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/8c/da/e273746b9d24a63c776bc60fba914351573ad9c575b52601eb5e60632564/tiktoken-0.14.0-cp312-cp312-macosx_10_13_x86_64.whl"
        sha256 "8e947aefe98ef74cce94923f90e48c98fe34eb1ec0a6bfdfadfc5a96359bfc36"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/51/11/9976ad86980a00cdef05e730a0127a2578a1bc6d11644d8d47246de2eb26/tiktoken-0.14.0-cp312-cp312-manylinux_2_28_x86_64.whl"
        sha256 "7896eea257fe497a2b7134474d909156c6744ce8da35bce88011a960e008aa0d"
      end
    end
  end

  resource "tree-sitter" do
    on_macos do
      on_arm do
        url "https://files.pythonhosted.org/packages/54/6f/8bb61957f16ec1b1d92410a006cdc84a952b6352a7313b2ad299f2d21484/tree_sitter-0.26.0-cp312-cp312-macosx_11_0_arm64.whl"
        sha256 "918d89529786873f0982a0f59c2a303cd065fbfd1b903d71a8e4e1584f67b42e"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/87/ca/565702c44815393e3a973552ad546db4e5ca081ca8698640b4e93d809f51/tree_sitter-0.26.0-cp312-cp312-macosx_10_13_x86_64.whl"
        sha256 "6cb2bd20efb2544c19ac54486ab7cb8ec7b36f913bbe1ce95df84acb96743d9c"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/8a/2f/6e6781b31677231366cb3cf27bc8269157f6d4b03c9032865a4f5f2bbe7e/tree_sitter-0.26.0-cp312-cp312-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "5a6b333b0282d8bb0af741f9b018bd2523d4eecb2686bf6717066a625fecfaa4"
      end
    end
  end

  resource "truststore" do
    url "https://files.pythonhosted.org/packages/19/97/56608b2249fe206a67cd573bc93cd9896e1efb9e98bce9c163bcdc704b88/truststore-0.10.4-py3-none-any.whl"
    sha256 "adaeaecf1cbb5f4de3b1959b42d41f6fab57b2b1666adb59e89cb0b53361d981"
  end

  resource "typer" do
    url "https://files.pythonhosted.org/packages/3f/f9/2b3ff4e56e5fa7debfaf9eb135d0da96f3e9a1d5b27222223c7296336e5f/typer-0.25.1-py3-none-any.whl"
    sha256 "75caa44ed46a03fb2dab8808753ffacdbfea88495e74c85a28c5eefcf5f39c89"
  end

  resource "typing-extensions" do
    url "https://files.pythonhosted.org/packages/49/d3/b8441a820a491ddfc024b0b0cf0393375b75ea13866d9c66727e54c2fc80/typing_extensions-4.16.0-py3-none-any.whl"
    sha256 "481caa481374e813c1b176ada14e97f1f67a4539ce9cfeb3f350d78d6370c2e8"
  end

  resource "typing-inspection" do
    url "https://files.pythonhosted.org/packages/67/81/4add07e5172b7ac40d8ed5ff580409a7801a4fe26d529bdd915401dabfbe/typing_inspection-0.4.4-py3-none-any.whl"
    sha256 "65b8397ba37ccbce054456aaccddfc91e6e3083c92824df348d96ca832f3f147"
  end

  resource "urllib3" do
    url "https://files.pythonhosted.org/packages/7f/3e/5db95bcf282c52709639744ca2a8b149baccf648e39c8cc87553df9eae0c/urllib3-2.7.0-py3-none-any.whl"
    sha256 "9fb4c81ebbb1ce9531cce37674bbc6f1360472bc18ca9a553ede278ef7276897"
  end

  resource "victor-ai" do
    url "https://files.pythonhosted.org/packages/6d/94/832358a27f0af77081ad29392579e3aa45fe8ab4d735a7d3dc747b0541c4/victor_ai-0.9.0-py3-none-any.whl"
    sha256 "7d00f09f02bb8cb9b68ffc56ff00a60b65238861b60a3431c347309f4ce6d831"
  end

  resource "victor-contracts" do
    url "https://files.pythonhosted.org/packages/e2/bd/344780b4d5a90a185fd02eeb14beec1a23f61ca1b5188ad4041470ff0c71/victor_contracts-0.9.0-py3-none-any.whl"
    sha256 "d906afa624bc21df9611e1a5f9f0eb923d56a9306967813217cec4dabe1ac243"
  end

  resource "wcwidth" do
    url "https://files.pythonhosted.org/packages/c4/0e/57f6bb3024a597b2e8ec4aee710ffe62ddc95af2e2bb1ee7a7abdc22c68c/wcwidth-0.8.3-py3-none-any.whl"
    sha256 "d5b73dba6158a595ec9370350e7f2637bcac8d6c5e4fde34f30fcffb6103a5e4"
  end

  resource "yarl" do
    url "https://files.pythonhosted.org/packages/61/02/962c1cbfc401a30c1d034dc67ff395f64b52302c6d62de556c1fca99acc0/yarl-1.24.5-py3-none-any.whl"
    sha256 "a33700d13d9b7d84fd10947b09ff69fb9a792e519c8cb9764a3ca70baa6c23a7"
  end

  def install
    venv = virtualenv_create(libexec, "python3.12")
    # Homebrew stages resources by unpacking them, which pip cannot install
    # for native wheels (only py3-none-any wheels get special-cased by the
    # stock helper). The cached downloads are already checksum-verified by
    # the resource blocks above, so install them as wheel files directly,
    # then the audited sdist last.
    stage = Pathname(Dir.mktmpdir("victor-wheels"))
    wheels = resources.map do |resource|
      cached = resource.cached_download
      # Homebrew's cache names look like "<sha256>--pkg-1.0-py3-none-any.whl";
      # pip parses the wheel filename and rejects the prefix, so copy each
      # wheel under its real name before installing.
      wheel = stage/cached.basename.sub(/\A\h{64}--/, "")
      cp cached, wheel
      wheel
    end
    venv.pip_install wheels
    venv.pip_install T.must(buildpath)
    # Copy victor's console scripts (per its dist-info entry points) rather
    # than using the stock symlink helper: pip skips entry points it cannot
    # generate (e.g. "benchmark"), so link exactly what exists.
    entry_points = libexec/"lib/python3.12/site-packages/victor_ai-#{version}.dist-info/entry_points.txt"
    entry_points.read.scan(/^([^#\s=]+)\s*=/).flatten.each do |script|
      script_file = libexec/"bin"/script
      bin.install script_file if script_file.exist?
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/victor --version")
  end
end
