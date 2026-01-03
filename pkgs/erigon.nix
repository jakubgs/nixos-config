{ pkgs ? import <nixpkgs> { } }:

# Can't use overrideAttrs due to how buildGoModule overwrites arguments.
pkgs.erigon.override {
  buildGoModule = args: pkgs.buildGo124Module ( args // rec {
    version = "3.3.2";

    src = pkgs.fetchFromGitHub {
      owner = "ledgerwatch";
      repo = args.pname;
      rev = "v${version}";
      hash = "sha256-jefTssNo1e0Bj/TxwQA4oxGKyJsVz0kZ5ncs/IjpswY=";
      fetchSubmodules = true;
    };

    vendorHash = "sha256-i/ri6HDaF8Mz7UgO14TPR1GBAxnmYuvWDP/B0L5gRd8=";

    subPackages = [
      "cmd/erigon"
    ];

    doCheck = false;
  });
}
