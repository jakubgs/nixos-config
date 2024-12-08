{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.erigon.override {
  buildGoModule = args: pkgs.buildGo122Module ( args // rec {
    version = "2.60.10";

    src = pkgs.fetchFromGitHub {
      owner = "ledgerwatch";
      repo = args.pname;
      rev = "v${version}";
      hash = "sha256-14s3Dfo1sqQlNZSdjByUCAsYzbv6xjPcCsBxEmoY3pU=";
      fetchSubmodules = true;
    };

    vendorHash = "sha256-I4rdz8dswA9/w4S9BNS43VTD9iDsH+cNK2haWowhBO4=";

    subPackages = [
      "cmd/erigon"
    ];

    # Silkworm is disabled for releases. Fails due to rpath.
    # Would require 'lib/linux_x64/libsilkworm_capi.so' from silkworm-go.
    tags = "-tags=nosqlite,noboltdb,nosilkworm";
  });
}
