{ pkgs, lib, config, secret, ... }:

let
  listenPort = 9802; # WebDAV Source TLS/SSL
  discoverPort = 9802; # WebDAV Source TLS/SSL
  services = config.services;
in {
  imports = [
    ../services/nimbus-eth2.nix
  ];

  options.nimbus = {
    feeRecipient = lib.mkOption { default = secret "service/nimbus/fee-recipient"; };
    jwtSecret    = lib.mkOption { default = secret "service/nimbus/web3-jws-secret"; };
  };

  config = let
    cfg = config.nimbus;
  in {
    # Secrets
    age.secrets."service/nimbus/fee-recipient" = {
      file = ../secrets/service/nimbus/fee-recipient.age;
      owner = "nimbus";
    };
    age.secrets."service/nimbus/web3-jws-secret" = {
      file = ../secrets/service/nimbus/web3-jws-secret.age;
      owner = "nimbus";
    };

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
      threadsNumber = 0; /* 0 == auto */
      /* Higher resource usage for small increase in rewards. */
      subAllSubnets = false;
      /* Costs two slot rewards at restart if enabled. */
      doppelganger = false;
      /* If Go-Ethereum is running use it. */
      execURLs =
        if services.erigon.enable       then ["http://localhost:${builtins.toString services.erigon.settings.${"authrpc.port"}}/"] else
        if services.geth.mainnet.enable then ["http://localhost:${builtins.toString services.geth.mainnet.authrpc.port}/"]
        else [];
      inherit (cfg) jwtSecret;
    };

    # Lock UID/GID
    users.users.nimbus.uid = 5000;
    users.groups.nimbus.gid = 5000;

    # Raise priority and add required volumes.
    systemd.services.nimbus-eth2 = {
      serviceConfig = {
        Nice = -20;
        IOSchedulingClass = "realtime";
        IOSchedulingPriority = 0;
        /* Address for transaction fee/priority rewards. */
        LoadCredential = [ "feeRecipient:${cfg.feeRecipient}" ];
      };
      # Wait for volume to be mounted
      after = lib.mkForce (map pkgs.lib.pathToMountUnit [
        "/mnt/nimbus" "/mnt/nimbus/validators" "/mnt/nimbus/secrets"
      ]);
    };
  };
}
