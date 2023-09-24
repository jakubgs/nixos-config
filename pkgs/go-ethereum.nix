{ pkgs ? import <nixpkgs-unstable> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo120Module ( args // rec {
    version = "1.13.1";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-eEoWuW4edH/2+GkHI/+bHoB4fgWjaPrCTz5ZmP6qzoY=";
    };

    vendorHash = "sha256-08jB8LWVnUzkisx0QqJPf7PTRf8inhPu3HboGZSqspo=";

    subPackages = [
      "cmd/ethkey"
      "cmd/clef"
      "cmd/geth"
      "cmd/utils"
    ];
  });
}
