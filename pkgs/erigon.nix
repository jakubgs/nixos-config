{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.erigon.override {
  buildGoModule = args: pkgs.buildGo123Module ( args // rec {
    version = "3.0.7";

    src = pkgs.fetchFromGitHub {
      owner = "ledgerwatch";
      repo = args.pname;
      rev = "v${version}";
      hash = "sha256-zx7bQQ+HUq+/ejNkfautRBwiMjApDDtT6jfhXGQ9MAU=";
      fetchSubmodules = true;
    };

    vendorHash = "sha256-ocnq97cMsiMgDTZhwZ/fiGzaHiSAiJckPwWZu2q3f58=";

    subPackages = [
      "cmd/erigon"
    ];

    doCheck = false;
  });
}
