{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo123Module ( args // rec {
    version = "1.15.11";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-2XGKkimwe9h8RxO3SzUta5Bh2Ooldl2LiHqUpn8FK7I=";
    };

    vendorHash = "sha256-R9Qg6estiyjMAwN6tvuN9ZuE7+JqjEy+qYOPAg5lIJY=";

    subPackages = [
      "cmd/ethkey"
      "cmd/clef"
      "cmd/geth"
      "cmd/utils"
    ];
  });
}
