{ lib, config, secret, ... }:

let
  listenPort = 9802; # WebDAV Source TLS/SSL
  discoverPort = 9802; # WebDAV Source TLS/SSL
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
    inherit listenPort discoverPort;
    log = { level = "info"; format = "json"; };
    metrics = { enable = true; address = "0.0.0.0"; };
    rest = { enable = true; address = "0.0.0.0"; };
    dataDir = "/mnt/nimbus";
    publicIp = secret "service/nimbus/public-ip";
    threadsNumber = 0; /* 0 == auto */
    /* Higher resource usage for small increase in rewards. */
    subAllSubnets = false;
    /* Costs two slot rewards at restart if enabled. */
    doppelganger = false;
    /* Address for transaction fee/priority tips. */
    suggestedFeeRecipient = secret "service/nimbus/fee-recipient";
    /* If Go-Ethereum is running use it. */
    web3Url = if services.geth.mainnet.enable
      then "http://localhost:${builtins.toString services.geth.mainnet.authrpc.port}/"
      else secret "service/nimbus/web3-url";
    jwtSecret = "/etc/nimbus-eth2/jwtsecret";
  };

  # Lock UID/GID
  users.users.nimbus.uid = 5000;
  users.groups.nimbus.gid = 5000;

  environment.etc."nimbus-eth2/jwtsecret" = {
    mode = "0440";
    user = services.nimbus-eth2.service.user;
    group = services.nimbus-eth2.service.group;
    text = secret "service/nimbus/web3-jws-secret";
  };

  systemd.services.nimbus-eth2 = {
    serviceConfig = {
      Nice = -20;
      IOSchedulingClass = "realtime";
      IOSchedulingPriority = 0;
      LoadCredential = [ "jwtsecret:/etc/nimbus-eth2/jwtsecret" ];
    };
    # Wait for volume to be mounted
    after = lib.mkForce (map pkgs.lib.pathToMountUnit [
      "/mnt/nimbus" "/mnt/nimbus/validators" "/mnt/nimbus/secrets"
    ]));
  };
}
