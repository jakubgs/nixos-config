{ pkgs, secret, ... }:

let
  devp2pPort = 9800; # WebDAV Source port
  publicIp = secret "service/geth/public-ip";

  gethPackage = pkgs.unstable.go-ethereum.geth.overrideAttrs (old: rec {
    version = "1.10.23";
    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = old.pname;
      rev = "v${version}";
      sha256 = "sha256-1fEmtbHKrjuyIVrGr/vTudZ99onkNjEMvyBJt4I8KK4=";
    };
  });
in {
  /* Firewall */
  networking.firewall.allowedTCPPorts = [ devp2pPort ];
  networking.firewall.allowedUDPPorts = [ devp2pPort ];

  services.geth = {
    "mainnet" = {
      enable = true;
      network = null; # mainnet
      syncmode = "snap";
      maxpeers = 50;
      port = devp2pPort;
      package = gethPackage;
      metrics = {
        enable = true;
        port = 16060;
        address = "0.0.0.0";
      };
      http = {
        enable = true;
        port = 18545;
        address = "0.0.0.0";
        apis = ["net" "eth" "admin"];
      };
      websocket = {
        enable = true;
        port = 18546;
        address = "0.0.0.0";
        apis = ["net" "eth" "admin"];
      };
      extraArgs = [
        "--v5disc"
        "--nat=extip:${publicIp}"
        "--authrpc.addr=127.0.0.1"
        "--authrpc.port=8551"
        "--authrpc.vhosts=localhost,127.0.0.1"
        "--authrpc.jwtsecret=/etc/geth/jwtsecret"
      ];
    };
  };

  environment.etc."geth/jwtsecret" = {
    # FIXME: Use LoadCredential instead.
    mode = "0444";
    text = secret "service/nimbus/web3-jws-secret";
  };
}
