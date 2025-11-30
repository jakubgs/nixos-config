{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.erigon.override {
  buildGoModule = args: pkgs.buildGo124Module ( args // rec {
    version = "3.3.0";

    src = pkgs.fetchFromGitHub {
      owner = "ledgerwatch";
      repo = args.pname;
      rev = "v${version}";
      hash = "sha256-5h9TxOvEfDbOkVTW6Py97sQRfomgu7U5w+iZvuZLri8=";
      fetchSubmodules = true;
    };

    vendorHash = "sha256-J/cEUrw9U67+CZmb1woI2HltYyo2v90ap/jiOqwMesY=";

    subPackages = [
      "cmd/erigon"
    ];

    doCheck = false;
  });
}
