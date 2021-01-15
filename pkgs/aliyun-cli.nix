{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation rec {
  pname = "aliyun-cli";
  version = "3.0.66";

  src = pkgs.fetchurl {
    url = "https://github.com/aliyun/aliyun-cli/releases/download/v${version}/aliyun-cli-linux-${version}-amd64.tgz";
    sha256 = "14brw03aqbxwhqkwdrjwli1s6qlg0shkl19rhn2cfd4jbc81wdvb";
  };

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  unpackPhase = ''
    unpackFile $src
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp aliyun $out/bin
  '';

  fixupPhase = ''
    INTERPRETER="$(cat $NIX_CC/nix-support/dynamic-linker)"
    patchelf --set-interpreter $INTERPRETER $out/bin/aliyun
  '';
}
