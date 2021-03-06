{ pkgs ? import <nixpkgs> { }, webui ? pkgs.fetchzip {
  name = "gossa-ui-26b93fd4b";
  url =
    "https://github.com/pldubouilh/gossa-ui/archive/26b93fd4bd969143105c23bc1bc644eeba000e13.zip";
  sha256 = "1va0kqawma9wavm0z59hnwywzivfm4c2bzjg7vjfipwhwkad6xgd";
} }:

pkgs.stdenv.mkDerivation rec {
  pname = "gossa";
  version = "0.1.7.1";
  goPackagePath = "github.com/pldubouilh/gossa";

  buildInputs = with pkgs; [ go perl ];

  src = pkgs.fetchzip {
    url = "https://github.com/pldubouilh/gossa/archive/v${version}.zip";
    sha256 = "0z49w8hzx3a70nbwhjy0d26nz8rijy9s0jjm9hka7vr66ldjwzw7";
  };

  configurePhase = ''
    HOME=$TMPDIR
    cp -r ${webui}/. gossa-ui/
  '';

  buildPhase = ''
    make build
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp gossa $out/bin
  '';
}
