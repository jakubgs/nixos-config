{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.erigon.override {
  buildGoModule = args: pkgs.buildGo125Module ( args // rec {
    version = "3.4.1";

    src = pkgs.fetchFromGitHub {
      owner = "ledgerwatch";
      repo = args.pname;
      rev = "v${version}";
      hash = "sha256-y8fRiWyjREW8c0GYMecIBXHnW/4+0a/1UYbcfdLIDmg=";
      fetchSubmodules = true;
    };

    vendorHash = "sha256-Y/I5LELaViHYjZsJolVwtcsG2Be79gMgocSaZ52tHXg=";

    subPackages = [
      "cmd/erigon"
    ];

    doCheck = false;
  });
}
