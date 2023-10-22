{ pkgs ? import <nixpkgs-unstable> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo120Module ( args // rec {
    version = "1.13.4";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-RQlWWHoij3gtFwjJeEGsmd5YJNTGX0I84nOAQyWBx/M=";
    };

    vendorHash = "sha256-YmUgKO3JtVOE/YACqL/QBiyR1jT/jPCH+Gb0xYwkJEc=";

    subPackages = [
      "cmd/ethkey"
      "cmd/clef"
      "cmd/geth"
      "cmd/utils"
    ];
  });
}
