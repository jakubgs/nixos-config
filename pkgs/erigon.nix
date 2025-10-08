{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.erigon.override {
  buildGoModule = args: pkgs.buildGo124Module ( args // rec {
    version = "3.2.0";

    src = pkgs.fetchFromGitHub {
      owner = "ledgerwatch";
      repo = args.pname;
      rev = "v${version}";
      hash = "sha256-PmQRNXHh39OR5XQqBheHUee/ugvK7oPZb4Lfh2Rn30U";
      fetchSubmodules = true;
    };

    vendorHash = "sha256-pAHIiRG6v2ARy95+rTZfFNoZ9xs82kvybH2kuWcpD8Q=";

    subPackages = [
      "cmd/erigon"
    ];

    doCheck = false;
  });
}
