{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.erigon.override {
  buildGoModule = args: pkgs.buildGo121Module ( args // rec {
    version = "2.60.1";

    src = pkgs.fetchFromGitHub {
      owner = "ledgerwatch";
      repo = args.pname;
      rev = "v${version}";
      hash = "sha256-VZzDG9qUjEBSNxQcmkqPTTDQjh7BZFqyRSaCfio8X2I=";
      fetchSubmodules = true;
    };

    vendorHash = "sha256-uOUnUvP0fhNYWSfICkqJV8aMI2f0017baP58VedPov4=";

    subPackages = [
      "cmd/erigon"
    ];

    # Silkworm is disabled for releases. Fails due to rpath.
    # Would require 'lib/linux_x64/libsilkworm_capi.so' from silkworm-go.
    tags = "-tags=nosqlite,noboltdb,nosilkworm";
  });
}
