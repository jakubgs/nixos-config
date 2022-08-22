{ lib, config, secret, ... }:

let
  listenPort = 9000;
  discoverPort = 9000;
  services = config.services;
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
    threadsNumber = 0; /* 0 == auto */
    /* Higher resource usage for small increase in rewards. */
    subAllSubnets = false;
    /* Costs two slot rewards at restart if enabled. */
    doppelganger = false;
    /* If Go-Ethereum is running use it. */
    web3Url = if services.geth.mainnet.enable
      then "http://localhost:${builtins.toString services.geth.mainnet.http.port}/"
      else secret "service/nimbus/web3-url";
    jwtSecret = "/etc/nimbus-eth2/jwtsecret";
  };

  environment.etc."nimbus-eth2/jwtsecret" = {
    mode = "0440";
    text = secret "service/nimbus/web3-jws-secret";
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
