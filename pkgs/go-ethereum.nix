{ pkgs ? import <nixpkgs> { } }:

pkgs.buildGoModule rec {
  pname = "go-ethereum";
  version = "1.17.7";

  src = pkgs.fetchFromGitHub {
    owner = "ethereum";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-FaVO1p7eZsXQN1Ikq2CcgiugHkSyETGagZLw6hIF7to=";
  };

  proxyVendor = true;
  vendorHash = "sha256-AsKicppcvr7xZ2sZ1pvsu8inXBRM1W3lFMlWAvV/EL0=";

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
