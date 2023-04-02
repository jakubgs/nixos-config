{ pkgs ? import <nixpkgs-unstable> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.go-ethereum.override {
  buildGoModule = args: pkgs.buildGo120Module ( args // rec {
    version = "1.11.5";

    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = args.pname;
      rev = "v${version}";
      sha256 = "sha256-QFqPAWW0L9cSBvnDwJKtwWT2jZFyr+zhYaS+GF/nQ9g=";
    };

    vendorSha256 = "sha256-Y1srOcXZ4rQ0QIQx4LdYzYG6goGk6oO30C+OW+s81z4=";

    subPackages = [
      "cmd/ethkey"
      "cmd/clef"
      "cmd/geth"
      "cmd/utils"
    ];
  });
}
