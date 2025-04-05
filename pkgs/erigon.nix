{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.erigon.override {
  buildGoModule = args: pkgs.buildGo122Module ( args // rec {
    version = "3.0.0";

    src = pkgs.fetchFromGitHub {
      owner = "ledgerwatch";
      repo = args.pname;
      rev = "v${version}";
      hash = "sha256-63wh9D5D9qzABEvKCBxBRHYuGBnlX+hrme56STkyoQU=";
      fetchSubmodules = true;
    };

    vendorHash = "sha256-Mvat9+mbgpept9g8pYNf4a/bAGZGBM0MAM417DDIT9w=";

    subPackages = [
      "cmd/erigon"
    ];

    doCheck = false;
  });
}
