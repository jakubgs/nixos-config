{ secret, ... }:

let
  devp2pPort = 30303;
  publicIp = secret "service/geth/public-ip";
in {
  services.geth = {
    "mainnet" = {
      enable = true;
      network = null; # mainnet
      syncmode = "snap";
      maxpeers = 50;
      port = devp2pPort;
      extraArgs = [
        "--v5disc"
        "--nat=extip:${publicIp}"
      ];
      metrics = {
        enable = true;
        port = 16060;
        address = "0.0.0.0";
      };
      http = {
        enable = true;
        port = 18545;
        address = "0.0.0.0";
        apis = ["net" "eth"];
      };
      websocket = {
        enable = true;
        port = 18546;
        address = "0.0.0.0";
        apis = ["net" "eth"];
      };
    };
  };

  /* Firewall */
  networking.firewall.allowedTCPPorts = [ devp2pPort ];
  networking.firewall.allowedUDPPorts = [ devp2pPort ];
}
