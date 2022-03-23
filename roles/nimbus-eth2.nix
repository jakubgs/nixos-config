{ lib, secret, ... }:

let
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
    logLevel = "info";
    logFormat = "json";
    dataDir = "/mnt/nimbus";
    publicIp = secret "service/nimbus/public-ip";
    web3Url = secret "service/nimbus/web3-url";
    threadsNumber = 0; /* 0 == auto */
    /* Higher resource usage for small increase in rewards. */
    subAllSubnets = true;
    /* Costs two slot rewards at restart if enabled. */
    doppelganger = false;
  };

  systemd.services.nimbus-eth2 = {
    serviceConfig = {
      Nice = -20;
      IOSchedulingClass = "realtime";
      IOSchedulingPriority = 0;
    };
    # Wait for volume to be mounted
    after = lib.mkForce ["mnt-nimbus.mount"];
  };
}
