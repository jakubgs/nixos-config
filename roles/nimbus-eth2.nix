{ ... }:

let
  secrets = import ../secrets.nix;

  listenPort = 9000;
  discoverPort = 9000;
in {
  imports = [
    ../services/nimbus-eth2.nix
  ];

  # Firewall
  networking.firewall.allowedTCPPorts = [ listenPort ];
  networking.firewall.allowedUDPPorts = [ discoverPort ];

  # Directory Watcher - Recursively starts torrents
  services.nimbus-eth2 = {
    enable = true;
    logLevel = "debug";
    dataDir = "/mnt/data/nimbus-eth2";
    publicIp = secrets.nimbusPublicIp;
    web3Url = secrets.nimbusWeb3Url;
  };
}
