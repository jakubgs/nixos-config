{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo124Module ( args // rec {
    version = "1.16.7";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-aAkF8WqYml359kTCWyfLH7yo1aIOGY31rZWEFFPyKgI=";
    };

    vendorHash = "sha256-KP9oD87kn8MCvEf3ply8HbP8xIBlGAEtthGob8Yh++A=";

    subPackages = [
      "cmd/ethkey"
      "cmd/clef"
      "cmd/geth"
      "cmd/utils"
    ];
  });
}
