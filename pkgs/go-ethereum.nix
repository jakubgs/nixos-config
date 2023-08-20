{ pkgs ? import <nixpkgs-unstable> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo120Module ( args // rec {
    version = "1.12.2";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-iCLOrf6/f0f7sD0YjmBtlcOcZRDIp9IZkBadTKj1Qjw=";
    };

    vendorHash = "sha256-ChmQjhz4dQdwcY/269Hi5XAn8/+0z/AF7Kd9PJ8WqHg=";

    subPackages = [
      "cmd/ethkey"
      "cmd/clef"
      "cmd/geth"
      "cmd/utils"
    ];
  });
}
