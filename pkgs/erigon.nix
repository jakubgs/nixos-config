{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.erigon.override {
  buildGoModule = args: pkgs.buildGo120Module ( args // rec {
    version = "2.54.0";

    src = pkgs.fetchFromGitHub {
      owner = "ledgerwatch";
      repo = args.pname;
      rev = "v${version}";
      hash = "sha256-1kgbIg/3SvVT83UfwAYUixs1RQk4PP1quiOcI1mzbZ0=";
      fetchSubmodules = true;
    };

    vendorHash = "sha256-Gr9mrME8/ZDxp2ORKessNhfguklDf+jC4RSpzLOSBhQ=";

    subPackages = [
      "cmd/erigon"
    ];

    # Fix error: 'Caught SIGILL in blst_cgo_init'
    # https://github.com/bnb-chain/bsc/issues/1521
    CGO_CFLAGS = "-O -D__BLST_PORTABLE__";
    CGO_CFLAGS_ALLOW = "-O -D__BLST_PORTABLE__";
  });
}
