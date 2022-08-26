{ pkgs, secret, ... }:

let
  devp2pPort = 9800; # WebDAV Source port
  publicIp = secret "service/geth/public-ip";
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
      package = pkgs.unstable.go-ethereum.geth;
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
