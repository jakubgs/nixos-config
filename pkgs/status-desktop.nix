{ pkgs ? import <nixpkgs> { } }:

let
  inherit (pkgs) lib stdenv appimageTools;

  name = "status-desktop";
  version = "0.4.0-48621b";
  appimage = stdenv.mkDerivation {
    name = "${name}-appimage";
    src = pkgs.fetchurl {
      url =
        "https://status-im-releases.ams3.digitaloceanspaces.com/StatusIm-Desktop-v${version}.tar.gz";
      sha256 = "0gkgaz3schb0ahmqkb0sv9p9qbh0wcbc7hqajcgnw7ixzqsl9d0d";
    };
    dontBuild = true;
    dontInstall = true;
    unpackPhase = ''
      tar xf $src 
      cp StatusIm-Desktop-v${version}.AppImage $out
    '';
  };
in appimageTools.wrapType1 {
  name = "${name}-${version}";
  src = appimage;

  meta = with lib; {
    description = "Status Desktop client made in Nim & QML";
    homepage = "https://status.im/";
    license = licenses.mpl20;
    maintainers = with maintainers; [ jakubgs ];
    platforms = [ "x86_64-linux" ];
  };
}
