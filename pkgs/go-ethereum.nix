{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo121Module ( args // rec {
    version = "1.13.14";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-+o/yOsS8tm8zvTJ17jd+dNPJpJB0vsjf4WRWNv6HgG0=";
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
