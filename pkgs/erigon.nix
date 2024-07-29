{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.erigon.override {
  buildGoModule = args: pkgs.buildGo121Module ( args // rec {
    version = "2.60.5";

    src = pkgs.fetchFromGitHub {
      owner = "ledgerwatch";
      repo = args.pname;
      rev = "v${version}";
      hash = "sha256-sI5XlPoHjAN3QsNWJXhi+qHDPVpcLqgX1hMa6gN5Iwc=";
      fetchSubmodules = true;
    };

    vendorHash = "sha256-wviIakonR5UDIoSb0eGFbinik5xouNjO6Q6DDxl2/xs=";

    subPackages = [
      "cmd/erigon"
    ];

    # Silkworm is disabled for releases. Fails due to rpath.
    # Would require 'lib/linux_x64/libsilkworm_capi.so' from silkworm-go.
    tags = "-tags=nosqlite,noboltdb,nosilkworm";
  });
}
