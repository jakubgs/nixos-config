{ pkgs ? import <nixpkgs-unstable> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo120Module ( args // rec {
    version = "1.12.0";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-u1p9k12tY79kA/2Hu109czQZnurHuDJQf/w7J0c8SuU=";
    };

    vendorHash = "sha256-k5MbOiJDvWFnaAPViNRHeqFa64XPZ3ImkkvkmTTscNA=";

    subPackages = [
      "cmd/ethkey"
      "cmd/clef"
      "cmd/geth"
      "cmd/utils"
    ];
  });
}
