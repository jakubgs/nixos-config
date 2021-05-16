{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation {
  pname = "linux-upgrade-tool";
  version = "1.59";

  src = pkgs.fetchurl {
    url = "https://github.com/rockchip-linux/tools/raw/d386f33f3f1d20af733dbee95dd358ba0edd5c72/linux/Linux_Upgrade_Tool/Linux_Upgrade_Tool/upgrade_tool";
    sha256 = "1g6ic4qm1dfw84kdm4gg8lhn601w3acafq459j0x7yz7bhn49a9q";
  };

  phases = [ "installPhase" "fixupPhase" ];

  installPhase = ''
    cp $src $out
    chmod +x $out
  '';

  meta = with pkgs.stdenv.lib; {
    description = "Rockchip Develop tools for flashing via USB-C";
    longDescription = "For flashing u-boot images to my NanoPC-T4";
    homepage = "https://github.com/rockchip-linux/tools";
    platforms = platforms.linux;
    maintainers = with maintainers; [ jakubgs ];
  };
}
