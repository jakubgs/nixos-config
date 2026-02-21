{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo124Module ( args // rec {
    version = "1.17.0";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-xTx2gcpDY4xuZOuUEmtV6m5NNO6YQ01tGzLr5rh9F/g=";
    };

    vendorHash = "sha256-egsqYaItRtKe97P3SDb6+7sbuvyGdNGIwCR6V2lgGOc=";

    subPackages = [
      "cmd/clef"
      "cmd/geth"
    ];
  });
}
