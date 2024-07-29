{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo121Module ( args // rec {
    version = "1.14.7";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-axllyeumgR6DJ5NXGBVanLcjfeDEHhBTRI9eiJUpFw4=";
    };

    vendorHash = "sha256-WN+3TN7opyS9mYSGbxZsDNNAAulaGqVjXNXW4JDRvvQ=";
    /* Fix for: fatal error: os/events_posix.h: No such file */
    proxyVendor = true;

    subPackages = [
      "cmd/ethkey"
      "cmd/clef"
      "cmd/geth"
      "cmd/utils"
    ];
  });
}
