{ pkgs ? import <nixpkgs> { } }:

pkgs.buildGoPackage rec {
  pname = "gossa";
  version = "v0.2.1";
  goPackagePath = "github.com/pldubouilh/gossa";

  src = pkgs.fetchgit {
    url = "https://github.com/pldubouilh/gossa";
    rev = version;
    sha256 = "sha256-TT9LtDQNyP9C7Lfb76U+IMR3E5B3pjR0x9UI0GdzqIo=";
    fetchSubmodules = true;
  };
}
