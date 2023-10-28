{ pkgs ? import <nixpkgs-unstable> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.erigon.override {
  buildGoModule = args: pkgs.buildGo120Module ( args // rec {
    version = "2.53.2";

    src = pkgs.fetchFromGitHub {
      owner = "ledgerwatch";
      repo = args.pname;
      rev = "v${version}";
      hash = "sha256-BFxqRPZIb4bM6a17UdFy/YB0frOnUC1UlVflo2EYgE8=";
      fetchSubmodules = true;
    };

    vendorHash = "sha256-415ALovZo6NjZD/yDw3ckYz2NCuNMYwV34Up7bTBdOQ=";

    subPackages = [
      "cmd/erigon"
    ];
  });
}
