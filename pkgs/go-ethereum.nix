{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo122Module ( args // rec {
    version = "1.14.11";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-y4tUV5TGhvvaLTukT0jVhoBWxXQlDFVKHScQC8Ytl/A=";
    };

    vendorHash = "sha256-xPFTvzsHMWVyeAt7m++6v2l8m5ZvnLaIDGki/TWe5kU=";
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
