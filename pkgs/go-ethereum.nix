{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo123Module ( args // rec {
    version = "1.15.5";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-kOgsjvkEi5acv53qnbyxMrPIXkz08SqjIO0A/mj/y90=";
    };

    vendorHash = "sha256-byp1FzB4cSk9TayjaamsVfgzX0H531kzSXVHxDgWTes=";
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
