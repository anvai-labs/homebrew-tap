# typed: false
# frozen_string_literal: true

class Victor < Formula
  include Language::Python::Virtualenv

  desc "Enterprise-Ready AI Coding Assistant - Any model, any provider"
  homepage "https://github.com/anvai-labs/victor"
  url "https://files.pythonhosted.org/packages/36/e9/a703d45ead2a866fd52bf759e68eaa826ef12e3cec3d1335b383aab8535f/victor_ai-0.13.1.tar.gz"
  sha256 "70ed10a6f3dd25c10ddce511685c3f8bbc430b794326a0869d4adea4f93b87b2"
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

  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/95/9c/c510029fc6ef33a6275cd2c5d3cecd6613dfd6aa401d57c54f1c18852ccf/setuptools-84.0.0-py3-none-any.whl"
    sha256 "51a52592b3b99e102b609654876bd65f19f999935166d1352678931132b0c670"
  end

  resource "wheel" do
    url "https://files.pythonhosted.org/packages/2e/29/69cfbb602cd91690c55d38ba9fe53e6a7e76a6fa647bf38f19c138d25449/wheel-0.48.0-py3-none-any.whl"
    sha256 "3217dcc807155e45db462d7ef2431f5ddda0d7273b700d05a67b271ceb1287ab"
  end

  resource "aiofiles" do
    url "https://files.pythonhosted.org/packages/bc/8a/340a1555ae33d7354dbca4faa54948d76d89a27ceef032c8c3bc661d003e/aiofiles-25.1.0-py3-none-any.whl"
    sha256 "abe311e527c862958650f9438e859c1fa7568a141b22abcd015e120e86a85695"
  end

  resource "aiohappyeyeballs" do
    url "https://files.pythonhosted.org/packages/71/43/1947f06babed6b3f1d7f38b0c767f52df66bfb2bc10b468c4a7de9eceff2/aiohappyeyeballs-2.7.1-py3-none-any.whl"
    sha256 "9243213661e29250eb41368e5daa826fc017156c3b8a11440826b2e3ed376472"
  end

  resource "aiohttp" do
    url "https://files.pythonhosted.org/packages/68/30/173960c42b05a6c59f7558e4b12a4b0d9ba376cf6aa9bde7f9e08a30ca8d/aiohttp-3.14.5-py3-none-any.whl"
    sha256 "efc21a454892828368b11c2c780de0ff8bc991f73f6b99c6b66e56205470929b"
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
    url "https://files.pythonhosted.org/packages/d1/65/54437e7edea49a3be9ef56f6b5965999bfdc52b9dadc9b448124ca51a594/anthropic-1.15.0-py3-none-any.whl"
    sha256 "10189a7993c5c71a0a2d4bb80020ca6a2fd27679f51e627405da37251d15ff49"
  end

  resource "anyio" do
    url "https://files.pythonhosted.org/packages/12/b8/4bd346e22b28902df4d651910f5242c28d84e4a5c2435ca5c3f797ed7e2e/anyio-4.15.1-py3-none-any.whl"
    sha256 "6152fdbbf9a77fdec97731721bebf7c4c44f7c29b424b0065826173efc7ed101"
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
    url "https://files.pythonhosted.org/packages/fb/dd/044062b61d94c59c29ad0da6918e6a21106f5b115096e9c87081cdd96167/cachetools-7.2.3-py3-none-any.whl"
    sha256 "85ef9d2703918bedf7f88caa0b06bb3bb7a71360eb0b05c20796b89fede6e30c"
  end

  resource "certifi" do
    url "https://files.pythonhosted.org/packages/0b/a7/71ac2cff56fec219ed242bb11b8efb69fcc4bec75db06fb7bfe35de520e6/certifi-2026.7.22-py3-none-any.whl"
    sha256 "62f22742b58a1a33014a2b6b706588a8d7e2a88ae7bd1a6ebe8c992928483775"
  end

  resource "charset-normalizer" do
    url "https://files.pythonhosted.org/packages/fc/ad/d07d7862a62ffa6d79d68074d14823243dd235a77c45262acbf6adeb28bf/charset_normalizer-3.5.2-py3-none-any.whl"
    sha256 "b6b751274acb69d77b3323d6b7dbaa3c7fdfc1eb829b7eb61d262f32e1af9685"
  end

  resource "click" do
    url "https://files.pythonhosted.org/packages/58/50/6c0d534c5f134586a8e1ba4e330569e32f057e33372ae556463212fb4cd3/click-8.5.0-py3-none-any.whl"
    sha256 "255bc9599cf7748b4b1a446ccc735421bd08a2ae529a8b88597d3de5664ee360"
  end

  resource "cvss" do
    url "https://files.pythonhosted.org/packages/63/6d/fe2c65b94a28ae0481dc254e8cd664b82390069003bea945076d8a445f2b/cvss-3.6-py2.py3-none-any.whl"
    sha256 "e342c6ad9c7eb69d2aebbbc2768a03cabd57eb947c806e145de5b936219833ea"
  end

  resource "docstring-parser" do
    url "https://files.pythonhosted.org/packages/a7/5f/ed01f9a3cdffbd5a008556fc7b2a08ddb1cc6ace7effa7340604b1d16699/docstring_parser-0.18.0-py3-none-any.whl"
    sha256 "b3fcbed555c47d8479be0796ef7e19c2670d428d72e96da63f3a40122860374b"
  end

  resource "frozenlist" do
    url "https://files.pythonhosted.org/packages/9a/9a/e35b4a917281c0b8419d4207f4334c8e8c5dbf4f3f5f9ada73958d937dcc/frozenlist-1.8.0-py3-none-any.whl"
    sha256 "0c18a16eab41e82c295618a77502e17b195883241c563b00f0aa5106fc4eaa0d"
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
    url "https://files.pythonhosted.org/packages/09/ba/a4568248771ce81957bfb7cc600264a40fbcda092391ee1c415c50be4bea/httpcore2-2.13.1-py3-none-any.whl"
    sha256 "e1e05d4f25f7d7d496bfb96748f6f4b67657b03da069b3a68c36069f3db73d0a"
  end

  resource "httpx" do
    url "https://files.pythonhosted.org/packages/2a/39/e50c7c3a983047577ee07d2a9e53faf5a69493943ec3f6a384bdc792deb2/httpx-0.28.1-py3-none-any.whl"
    sha256 "d909fcccc110f8c7faf814ca82a9a4d816bc5a6dbfea25d6591d6985b8ba59ad"
  end

  resource "httpx2" do
    url "https://files.pythonhosted.org/packages/d8/9c/6fe8931fd9f381042a9e4c7d5a7b4cbf7016b252bec0c99a49fce42c3326/httpx2-2.13.1-py3-none-any.whl"
    sha256 "6dff50fabc270ee5fd25d845d0b078ed20564579744d6d962850975996d2f9a4"
  end

  resource "idna" do
    url "https://files.pythonhosted.org/packages/58/a2/bb081bab032533a855d44de1d56f8e8426114ff1ba5d1f07a438a0a654f8/idna-3.20-py3-none-any.whl"
    sha256 "ab7ae7122974553370f0bdb919e1a960b2cd1bc1ef0276416d896db81c14582c"
  end

  resource "jiter" do
    on_macos do
      on_arm do
        url "https://files.pythonhosted.org/packages/0e/5e/0de4c6f84ffefa6809ffc2d550b9a314365acf7e7ec9b6c7375d49047900/jiter-0.17.0-cp312-cp312-macosx_11_0_arm64.whl"
        sha256 "61aed66ee042b3b49ef85fdf75714234d055d89d8496ac1c6e47f89e7a30d5e4"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/aa/f8/07bd8c3a23f7a8a6875e6a820bbffe1483a18f18f9398a91b5495123176e/jiter-0.17.0-cp312-cp312-macosx_10_12_x86_64.whl"
        sha256 "ebf918dfd6a74adc1b9ad71f63c4ab00902fcd3b7fd39f2e24d871db8d713b91"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/52/f8/b6e513ecbdf3b3cebe587c2279281ecf775b729a58cf4cc7bdf898ded029/jiter-0.17.0-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "8c21265b251d99bbb40080d178a8953e35601d3a1564e05c4de4c0d2ca616797"
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

  resource "lxml" do
    on_macos do
      on_arm do
        url "https://files.pythonhosted.org/packages/dd/1f/a180b57d9eeabaab77f9d5aa30356898ea749c4795596a8f66d1eb6bef2e/lxml-6.1.3-cp312-cp312-macosx_10_13_universal2.whl"
        sha256 "0c0710ac085a157b593c38fbcacd950f15c4afa8e2057527185875ab302752bc"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/dd/1f/a180b57d9eeabaab77f9d5aa30356898ea749c4795596a8f66d1eb6bef2e/lxml-6.1.3-cp312-cp312-macosx_10_13_universal2.whl"
        sha256 "0c0710ac085a157b593c38fbcacd950f15c4afa8e2057527185875ab302752bc"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/db/36/aa413bc214dc4f785ad2b2ddd8cc99aae7062d49ab155e91e6011af00daf/lxml-6.1.3-cp312-cp312-manylinux2014_x86_64.manylinux_2_17_x86_64.whl"
        sha256 "379f8a75cf6eb7eef0af074b55f49ab73b868388a98de14646abcdfa4564bb11"
      end
    end
  end

  resource "markdown-it-py" do
    url "https://files.pythonhosted.org/packages/b3/81/4da04ced5a082363ecfa159c010d200ecbd959ae410c10c0264a38cac0f5/markdown_it_py-4.2.0-py3-none-any.whl"
    sha256 "9f7ebbcd14fe59494226453aed97c1070d83f8d24b6fc3a3bcf9a38092641c4a"
  end

  resource "mdurl" do
    url "https://files.pythonhosted.org/packages/b3/38/89ba8ad64ae25be8de66a6d463314cf1eb366222074cfda9ee839c56a4b4/mdurl-0.1.2-py3-none-any.whl"
    sha256 "84008a41e51615a49fc9966191ff91509e3c40b939176e643fd50a5c2196b8f8"
  end

  resource "multidict" do
    url "https://files.pythonhosted.org/packages/d0/86/a3de309c5e28ee85b314d0e3ba0e0dea6fd361c313322a05e67be4656e1e/multidict-7.1.0-py3-none-any.whl"
    sha256 "d9ef29cfd98e17085b4f91bba8fa1570bec6787d5c52ce653ed33a58785585d0"
  end

  resource "openai" do
    url "https://files.pythonhosted.org/packages/03/2a/cf8077a715ffd5e426a2e010357e9b72c1fcf7232ae58687b8e10b7a622d/openai-3.34.0-py3-none-any.whl"
    sha256 "49db52e2b7175a8ec0deb2878b0de957250b5e5451bbfb725258119e6e4bfa15"
  end

  resource "opentelemetry-api" do
    url "https://files.pythonhosted.org/packages/1e/41/f7dcf80b81ee8e71c1a2b59f14208bc723edbd89ed027a73b175abf6348e/opentelemetry_api-1.45.1-py3-none-any.whl"
    sha256 "b31553efa588ae44bc306f863c785c5333a9ecc091248c6ee68b4b6c87fdedfb"
  end

  resource "orjson" do
    on_macos do
      on_arm do
        url "https://files.pythonhosted.org/packages/98/17/ed65f84ed5ed6a1e06eb628611b4172e7480fc4ad92594856751a6363cac/orjson-3.13.0-cp312-cp312-macosx_10_15_x86_64.macosx_11_0_arm64.macosx_10_15_universal2.whl"
        sha256 "fb8644dc6d705e1269ed2842bf4dbe2b4e50d670de503bf79d5cef3a5148a4c7"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/98/17/ed65f84ed5ed6a1e06eb628611b4172e7480fc4ad92594856751a6363cac/orjson-3.13.0-cp312-cp312-macosx_10_15_x86_64.macosx_11_0_arm64.macosx_10_15_universal2.whl"
        sha256 "fb8644dc6d705e1269ed2842bf4dbe2b4e50d670de503bf79d5cef3a5148a4c7"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/ea/8c/bb07c368abbf4021c4cd01c12edb526e00090f7f750ff1b88da6e6b6c7a6/orjson-3.13.0-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "bceadfd314bd238f584fc229a4bbaf0e573597e7a026dec5429fbf29fd66c641"
      end
    end
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/63/34/ba1c580383c9eada3711951fef0795c80b829a078d72188184bcab9dd527/packaging-26.3-py3-none-any.whl"
    sha256 "d7193f7c8e4e93f444fde0262bf90af30e16fa0ad0ad44cb553c87339b23cd1c"
  end

  resource "prompt-toolkit" do
    url "https://files.pythonhosted.org/packages/54/6f/84908cad2d6aa5144abcf7b42709fe4fdb459bc640ec7ac5786e7693dabc/prompt_toolkit-3.0.53-py3-none-any.whl"
    sha256 "01c0891d7f9237d5e339f7d3e42cdae80b7534abb1c7c0e3352efba6231492f2"
  end

  resource "propcache" do
    url "https://files.pythonhosted.org/packages/f5/cd/785c64ed382f3f04201870267b02783f63b4678c2acfddc177a3ebcc2727/propcache-0.5.4-py3-none-any.whl"
    sha256 "62c60aec739ed00124573cce1178138fd690c7676352d67a37328c1cf51d7468"
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
    url "https://files.pythonhosted.org/packages/35/ea/a56b9fe5066f3537b7882f77e9c5dfb26d8c2eefdaed9b5fc73d57b4dc22/pydantic-2.14.1-py3-none-any.whl"
    sha256 "9195d967ec791692a04438115466764fb8b9a27b31f14a760437694f40d6b454"
  end

  resource "pydantic-core" do
    on_macos do
      on_arm do
        url "https://files.pythonhosted.org/packages/db/a3/f8b1b39349c33037c73d7a1b794c9c29d8f07d5bd2b74399c1375a529cc6/pydantic_core-2.50.1-cp312-cp312-macosx_11_0_arm64.whl"
        sha256 "e8e1d6ce820aa23317e8209a86bd65a540973c12dc7552b48a4f6c8e9926815e"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/ee/94/101b49a6c63f99586755690696eae14532772587d9e39e93f7b8d28a49da/pydantic_core-2.50.1-cp312-cp312-macosx_10_12_x86_64.whl"
        sha256 "704075d10b74f2f3c6e15407c696d88701df35fc8953f434a431add0d0074db0"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/90/24/48cd98388e4ac2c08d0800af36d15413db15e20387f1038123a2c86cb2f6/pydantic_core-2.50.1-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "93ba4e9d8210d941c200431a56b2c0400b131865947903937ed3ec5404307d2e"
      end
    end
  end

  resource "pydantic-settings" do
    url "https://files.pythonhosted.org/packages/53/f4/b987bf8c51e5b19a95fa66d1ee596074141e085d9c2ddf97920803c7029b/pydantic_settings-2.16.0-py3-none-any.whl"
    sha256 "7e73acf7f61936a15e5a3b6eedaea29f133357faf7272f2607ba479b049dd7f2"
  end

  resource "pygments" do
    url "https://files.pythonhosted.org/packages/71/46/17f022dd3e953bf20a04a028a21ec746d942f8d2af30fa0f124fa0e6a684/pygments-2.21.0-py3-none-any.whl"
    sha256 "2363c69b61c4a97c838da3b130dcd6468f4848992b21a82f2a63ec34377137d9"
  end

  resource "python-dotenv" do
    url "https://files.pythonhosted.org/packages/60/d1/38f3a3405989a89ac18390803e70c6ad7c7760da4f9b83cbeca0c44a0c72/python_dotenv-1.2.4-py3-none-any.whl"
    sha256 "42269a8a5b3fd54ffa6f3d84b18abed50064717576b4ecf03dc4a55d8aa04fdc"
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
        url "https://files.pythonhosted.org/packages/84/48/3fdcde9a0baa84d7d25571223265d6e434e114763b438601d54a8028bf3e/regex-2026.9.29-cp312-cp312-macosx_10_13_universal2.whl"
        sha256 "dc79d36d0618752265f0d575915bdc5c5130ecb9c9f6b3bcefeae32e4bdfafcf"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/84/48/3fdcde9a0baa84d7d25571223265d6e434e114763b438601d54a8028bf3e/regex-2026.9.29-cp312-cp312-macosx_10_13_universal2.whl"
        sha256 "dc79d36d0618752265f0d575915bdc5c5130ecb9c9f6b3bcefeae32e4bdfafcf"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/26/83/d2fbd2e4e3afb1167daa825187d196f313cbaa1a4768f311fb041bb0e3d2/regex-2026.9.29-cp312-cp312-manylinux2014_x86_64.manylinux_2_17_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "39ab5894d971f9ac68baa6eca5c50387db579cfcacf36ae8df3feceb1815e6d0"
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
        url "https://files.pythonhosted.org/packages/90/81/ac6a0d064982251856ce009c9e1dd51a34110b3c055aa7d1aad18b4899a3/rpds_py-2026.9.1-cp312-cp312-macosx_11_0_arm64.whl"
        sha256 "e21c1429e205828ea886a2293a4a2c8e01f4c25d9893ca330e97a6cf73f52e7b"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/5d/34/a828586ea3329fbb50895b50e9cf98ca3d924a9f41a0b26d443bff1b3794/rpds_py-2026.9.1-cp312-cp312-macosx_10_12_x86_64.whl"
        sha256 "50906f5aea24b5a865cbd0a589698288631d9f3a54c3a937c83aefa95a0d14af"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/1d/6d/b26eb1e75395925b3a142ed351cbed2ec8212f5c9d937aee3df32c701baa/rpds_py-2026.9.1-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "addeda51556dac7c1a2f14cda62db8b621cd12afba3091d03a96c72932387eab"
      end
    end
  end

  resource "sandhi-gateway" do
    on_macos do
      on_arm do
        url "https://files.pythonhosted.org/packages/b3/5f/7fcdb7acd2bb2fe300384e2104d18eae3438773593c546c579663b772240/sandhi_gateway-0.14.0-cp311-abi3-macosx_11_0_arm64.whl"
        sha256 "38901b14404add4a4dd79a4eda4da28495552b64b5c636db1dbbb477560a7f76"
      end
    end
    on_linux do
      on_intel do
        url "https://files.pythonhosted.org/packages/bf/e1/e43d5b13534a03f289f0bacd9c9b7480b0af95549a5dd6e9c1a002081cdd/sandhi_gateway-0.14.0-cp311-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl"
        sha256 "6b7d4e993104f18ae8509d0bf27c1589f0a7229d0b7667aeb1c7ffb6719fc14b"
      end
    end
  end

  resource "shellingham" do
    url "https://files.pythonhosted.org/packages/e0/f9/0595336914c5619e5f28a1fb793285925a8cd4b432c9da0a987836c7f822/shellingham-1.5.4-py2.py3-none-any.whl"
    sha256 "7ecfff8f2fd72616f7481040475a65b2bf8af90a56c89140852d1120324e8686"
  end

  resource "sniffio" do
    url "https://files.pythonhosted.org/packages/e9/44/75a9c9421471a6c4805dbf2356f7c181a29c1879239abab1ea2cc8f38b40/sniffio-1.3.1-py3-none-any.whl"
    sha256 "2f6da418d1f1e0fddd844478f41680e794e6051915791a034ff65e5f100525a2"
  end

  resource "soupsieve" do
    url "https://files.pythonhosted.org/packages/49/ca/f639c80449997b88aba7bc9705d25dd76cc0844f45f187862fd8f8bb18fa/soupsieve-3.0.3-py3-none-any.whl"
    sha256 "fa30e3ba4809cb81ce1f3209f2fbe3e779fc445f0439bc147a0d7c4601743f21"
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
    url "https://files.pythonhosted.org/packages/51/e9/3a7820be2bb0fe53b6bc9c3be26d3d1158004e4c3ab953aa6840b955b1e9/truststore-0.10.5-py3-none-any.whl"
    sha256 "9aaaedaefaf06d8b206278cf8b5012bc897f485a874503501e12d776df78951c"
  end

  resource "typer" do
    url "https://files.pythonhosted.org/packages/07/ea/2e31b67051e91a133189e9c000c222502ddc6969856416de0d095de4c0b0/typer-0.27.3-py3-none-any.whl"
    sha256 "e50022f28b82a86313e54501317a1db64bf8f8d036ff8cfe5ca7e47675454aff"
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
    url "https://files.pythonhosted.org/packages/92/9d/c4e665119135114480843e7ab388fa94d8480650450e6f8e26b70d323a4c/urllib3-2.8.0-py3-none-any.whl"
    sha256 "0cf3cae568d36aa9576b28dfb35f11328f1cb974ca7647d9475ebb86c75ac6e3"
  end

  resource "victor-contracts" do
    url "https://files.pythonhosted.org/packages/9b/a3/bdf59ff6650930c29ec83c3722dfaf801a9dc21bf51cd4c844cef5ff19de/victor_contracts-0.10.0-py3-none-any.whl"
    sha256 "c533fb94c13d35f257d32ed4fe9a3b5507f9d6e3feb385808e14f8b5080bd76c"
  end

  resource "wcwidth" do
    url "https://files.pythonhosted.org/packages/9c/b4/0bfa065af506540d9d558e3e5548cff00bc1f9b24e6e2a8512498e8628de/wcwidth-0.9.2-py3-none-any.whl"
    sha256 "89ca642c5bf0101157a09366be69fad0379db1f700ae39a920e103234573670e"
  end

  resource "yarl" do
    url "https://files.pythonhosted.org/packages/54/22/318c7980066769c6bcd9221ed2248294f5698811da099013098c670565ed/yarl-1.25.1-py3-none-any.whl"
    sha256 "681c758b0490f9e96b78e5fa8e8dc6e648e9185bb6eaebe73183c33ea0c445f3"
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
    venv.pip_install T.must(buildpath), build_isolation: false
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
