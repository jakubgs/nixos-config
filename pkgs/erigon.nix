{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.erigon.override {
  buildGoModule = args: pkgs.buildGo121Module ( args // rec {
    version = "2.58.1";

    src = pkgs.fetchFromGitHub {
      owner = "ledgerwatch";
      repo = args.pname;
      rev = "v${version}";
      hash = "sha256-jeOV86QVRQ6RiXUPesa+RbYgSe/t43xYZ8X9t/d9fMs=";
      fetchSubmodules = true;
    };

    vendorHash = "sha256-DOsM0G0idAHUsil4KNkmghq3VZwVE1ub6fAvRnELHn0=";

    subPackages = [
      "cmd/erigon"
    ];

    # Silkworm is disabled for releases. Fails due to rpath.
    # Would require 'lib/linux_x64/libsilkworm_capi.so' from silkworm-go.
    tags = "-tags=nosqlite,noboltdb,nosilkworm";
  });
}
