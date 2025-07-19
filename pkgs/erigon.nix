{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.erigon.override {
  buildGoModule = args: pkgs.buildGo123Module ( args // rec {
    version = "3.0.14";

    src = pkgs.fetchFromGitHub {
      owner = "ledgerwatch";
      repo = args.pname;
      rev = "v${version}";
      hash = "sha256-CZEzTJcjUZy4Fc7HHHklZJLlBwLE/fP+uyqBTzLox0U=";
      fetchSubmodules = true;
    };

    vendorHash = "sha256-ocnq97cMsiMgDTZhwZ/fiGzaHiSAiJckPwWZu2q3f58=";

    subPackages = [
      "cmd/erigon"
    ];

    doCheck = false;
  });
}
