{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo120Module ( args // rec {
    version = "1.13.5";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-UbRsY9fSUYAwPcLfGGDHeqvSsLKUKR+2a93jH5xA9uQ=";
    };

    vendorHash = "sha256-dOvpOCMxxmcAaticSLVlro1L4crAVJWyvgx/JZZ7buE=";

    subPackages = [
      "cmd/ethkey"
      "cmd/clef"
      "cmd/geth"
      "cmd/utils"
    ];
  });
}
