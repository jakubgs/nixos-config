{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
  pname = "rockchip-upgrade-tool";
  version = "1.54";

  src = pkgs.fetchurl {
    url = "https://github.com/rockchip-linux/rkbin/raw/master/tools/upgrade_tool";
    sha256 = "sha256-Z0iUUpDWPRGbVCueEjoIllEOmOiwpvSsJ5yKUn2mIQI=";
  };

  phases = [ "installPhase" "fixupPhase" ];

  installPhase = ''
    mkdir $out/bin
    cp $src $out/bin/
    chmod +x $out/bin/upgrade_tool
  '';

  meta = with pkgs.lib; {
    description = "Rockchip Develop tools for flashing via USB-C";
    longDescription = "For flashing u-boot images to my NanoPC-T4";
    homepage = "https://github.com/rockchip-linux/rkbin";
    platforms = platforms.linux;
    maintainers = with maintainers; [ jakubgs ];
  };
}
