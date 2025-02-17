{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo122Module ( args // rec {
    version = "1.15.2";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-eaUkPl8vQzvotYfZcnuBwphSfO33RPjWOYhyNNvXli4=";
    };

    vendorHash = "sha256-cfBTSroeDb/htGzIWG8c9Jty+Qo0TrQBrnyYy/Yo2C4=";
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
