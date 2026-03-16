{ pkgs ? import <nixpkgs> { } }:

pkgs.go-ethereum.overrideAttrs (args: rec {
  version = "1.17.1";

  src = pkgs.fetchFromGitHub {
    owner = "ethereum";
    repo = args.pname;
    rev = "v${version}";
    sha256 = "sha256-Fg+xitRROkLVXIpCoQ78eY/RFRcj7pBPI4kTSLLl+pw=";
  };

  vendorHash = "sha256-S/CkTWx4fUI54JVCW9ixhNADdBuMD2i7NI5U8aDy66k=";

  subPackages = [
    "cmd/clef"
    "cmd/geth"
  ];
})
