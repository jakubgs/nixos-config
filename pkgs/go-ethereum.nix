{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo123Module ( args // rec {
    version = "1.15.10";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-QVgi4IDPDGlvg8J3Wwrjtzkd6eYi3aAwU8IJbnIr5fU=";
    };

    vendorHash = "sha256-1FuVdx84jvMBo8VO6q+WaFpK3hWn88J7p8vhIDsQHPM=";
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
