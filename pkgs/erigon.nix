{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.erigon.override {
  buildGoModule = args: pkgs.buildGo123Module ( args // rec {
    version = "3.0.2";

    src = pkgs.fetchFromGitHub {
      owner = "ledgerwatch";
      repo = args.pname;
      rev = "v${version}";
      hash = "sha256-1rMlRlEUheW6g3kigh+DjQxtNJOrqrADPkjQn7TQr1g=";
      fetchSubmodules = true;
    };

    vendorHash = "sha256-tCohubwCk5HERoAaGWgEsl5kpI8w8dn0oZCZ2AxkKXk=";

    subPackages = [
      "cmd/erigon"
    ];

    doCheck = false;
  });
}
