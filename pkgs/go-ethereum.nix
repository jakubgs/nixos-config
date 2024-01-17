{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo121Module ( args // rec {
    version = "1.13.10";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-HFAf5fjYiRx6OEbqdtgaan8bqZPHazYKWG2Ty+WhNu8=";
    };

    vendorHash = "sha256-w4WUDLzpr0VTwLK84/Yq4ia3Q1XhxDttzQ5RGg2FQGU=";

    subPackages = [
      "cmd/ethkey"
      "cmd/clef"
      "cmd/geth"
      "cmd/utils"
    ];
  });
}
