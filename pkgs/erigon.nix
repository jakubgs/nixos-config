{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.erigon.override {
  buildGoModule = args: pkgs.buildGo122Module ( args // rec {
    version = "2.61.3";

    src = pkgs.fetchFromGitHub {
      owner = "ledgerwatch";
      repo = args.pname;
      rev = "v${version}";
      hash = "sha256-VGLuPaGYx/DQc3Oc9wAbELXAtkuxr8cbePVBExlZikk=";
      fetchSubmodules = true;
    };

    vendorHash = "sha256-1LB2T0o9LjFdpl86NPMKx1lFLrQZefAGldcSQyL6O7M=";

    subPackages = [
      "cmd/erigon"
    ];

    # Silkworm is disabled for releases. Fails due to rpath.
    # Would require 'lib/linux_x64/libsilkworm_capi.so' from silkworm-go.
    tags = "-tags=nosqlite,noboltdb,nosilkworm";
  });
}
