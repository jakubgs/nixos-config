{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo121Module ( args // rec {
    version = "1.13.13";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-MfsRWJU59mGjjzioqmMqKJoZks+XxlALkyOIC/xI1KU=";
    };

    vendorHash = "sha256-LWNFuF66KudxrpWBBXjMbrWP5CwEuPE2h3kGfILIII0=";

    subPackages = [
      "cmd/ethkey"
      "cmd/clef"
      "cmd/geth"
      "cmd/utils"
    ];
  });
}
