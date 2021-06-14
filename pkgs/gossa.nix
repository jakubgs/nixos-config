{ pkgs ? import <nixpkgs> { }, webui ? pkgs.fetchzip {
  name = "gossa-ui-a057f08e";
  url =
    "https://github.com/pldubouilh/gossa-ui/archive/a057f08e1d9fdbb9556c7f36626cd91f41d267d9.zip";
  sha256 = "1wc2va74dns3wn1cd5m2chqqiqgs75pczdc8r0zvwzcc5i066fh6";
} }:

pkgs.stdenv.mkDerivation rec {
  pname = "gossa";
  version = "0.1.8.0";
  goPackagePath = "github.com/pldubouilh/gossa";

  buildInputs = with pkgs; [ go perl ];

  src = pkgs.fetchzip {
    url = "https://github.com/pldubouilh/gossa/archive/v${version}.zip";
    sha256 = "0pd3wmrfadan3k5gvjhpcznjhariqvh23a95fw273c6r8smqx50g";
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
