{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.erigon.override {
  buildGoModule = args: pkgs.buildGo123Module ( args // rec {
    version = "3.0.3";

    src = pkgs.fetchFromGitHub {
      owner = "ledgerwatch";
      repo = args.pname;
      rev = "v${version}";
      hash = "sha256-gSgkdg7677OBOkAbsEjxX1QttuIbfve2A3luUZoZ5Ik=";
      fetchSubmodules = true;
    };

    vendorHash = "sha256-8eyC3JkRcRlFw8CyTK5w1XySur2jAeFGXkEaY/3Oq0k=";

    subPackages = [
      "cmd/erigon"
    ];

    doCheck = false;
  });
}
