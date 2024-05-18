{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo121Module ( args // rec {
    version = "1.14.3";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-h2i/q4gfvqO8SgFxjoIhm4y0icpt+qe0Tq+3W6Ld8KM=";
    };

    vendorHash = "sha256-yD4Z7vbi3D3f9xGxRQjnjbTKljtjRLeIHRAdWjSub6U=";
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
