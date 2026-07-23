{ pkgs ? import <nixpkgs> { } }:

pkgs.buildGoModule rec {
  pname = "go-ethereum";
  version = "1.17.4";

  src = pkgs.fetchFromGitHub {
    owner = "ethereum";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-jgBKoSt3cdw3NyTi8SLBf28tvJIBAitkQNMlzfnIONE=";
  };

  proxyVendor = true;
  vendorHash = "sha256-18rqbSx3JGaQz3Fw38JShRikkTT4Gn+uqqbNZiJQaS8=";

  ldflags = ["-s" "-w"];

  doCheck = false;

  subPackages = [ "cmd/geth" ];

  meta = with pkgs.lib; {
    description = "Official golang implementation of the Ethereum protocol";
    homepage = "https://geth.ethereum.org/";
    license = with licenses; [lgpl3Plus gpl3Plus];
    mainProgram = "geth";
    platforms = ["x86_64-linux" "aarch64-linux"];
  };
}
