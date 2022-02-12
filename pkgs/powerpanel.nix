{ pkgs ? import <nixpkgs> { } }:

let
  inherit (pkgs) lib stdenv openssl json_c aws-c-mqtt;
in stdenv.mkDerivation rec {
  pname = "powerpanel";
  version = "1.4.1";

  #src = ./powerpanel-x86_64-v1.4.1.tar.gz;
  src = pkgs.fetchurl {
    name = "powerpanel-x86_64-v1.4.1.tar.gz";
    url = "https://www.cyberpower.com/global/en/File/GetFileSampleByType?fileId=SU-18070001-08&fileType=Download%20Center&fileSubType=FileOriginal";
    sha256 = "sha256-YkDa5ZICUx35HM8GVc9sYRIP5k3BRkLEZXk2btDYIS0=";
  };

  installPhase = ''
    mkdir -p $out
    cp -r . $out
  '';

  fixupPhase = ''
    for BIN in $(find $out/bin -type f); do
      patchelf $BIN \
        --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) \
        --add-needed $out/lib/libcrypto.so.1.1 \
        --add-needed $out/lib/libssl.so.1.1 \
        --add-needed $out/lib/libjson-c.so.5.1.0 \
        --add-needed $out/lib/libpaho-mqtt3cs.so.1.3.1
    done
  '';

  meta = with lib; {
    description = "Simple command line Linux daemon to control a UPS system";
    homepage = "https://www.cyberpower.com/global/en/product/sku/powerpanel%C2%AE_for_linux#overview";
    #license = licenses.unfree;
    maintainers = with maintainers; [ jakubgs ];
    platforms = [ "x86_64-linux" ];
  };
}
