{ config, pkgs, lib, secret, ... }:

{
  options.erigon = {
    devp2pPort = lib.mkOption { default = 9800; };
    jwtSecret  = lib.mkOption { default = secret "service/nimbus/web3-jwt-secret"; };
  };

  config = let
    cfg = config.erigon;
  in {
    age.secrets."service/nimbus/web3-jwt-secret" = {
      file = ../secrets/service/nimbus/web3-jwt-secret.age;
      owner = "nimbus";
    };

    services.erigon = {
      enable = true;
      package = pkgs.callPackage ../pkgs/erigon.nix { };
      secretJwtPath = cfg.jwtSecret;
      settings = {
        "chain" = "mainnet";
        "mine" = true;
        "miner.etherbase" = secret "service/nimbus/fee-recipient";
        "allow-insecure-unlock" = true;
        "maxpeers" = 100;
        "datadir" = "/mnt/erigon";
        "log.console.json" = true;
        "log.console.verbosity" = "info";
        # DevP2P
        "port" = cfg.devp2pPort;
        "p2p.allowed-ports" = [cfg.devp2pPort (cfg.devp2pPort+1)];
        # RPC
        "http.addr" = "localhost";
        "http.port" = 18545;
        # AuthRPC / Engine API
        "authrpc.addr" = "localhost";
        "authrpc.port" = 18551;
        "authrpc.vhosts" = "localhost,127.0.0.1,${config.networking.hostName}";
        # Metrics
        "metrics" = true;
        "metrics.addr" = "0.0.0.0";
        "metrics.port" = 16060;
      };
    };

    # Custom user
    users.groups.erigon.gid = 500;
    users.users.erigon = {
      uid = 500;
      group = "erigon";
      isSystemUser = true;
    };
    systemd.services.erigon = {
      # Wait for torrent volume to be mounted.
      after = lib.mkForce [
        "network.target" (
          pkgs.lib.pathToMountUnit config.services.erigon.settings.datadir
        )
      ];
      serviceConfig = {
        User = "erigon";
        DynamicUser = lib.mkForce false;
      };
    };

    /* Firewall */
    networking.firewall.allowedTCPPorts = [ cfg.devp2pPort ];
    networking.firewall.allowedUDPPorts = [ cfg.devp2pPort ];
  };
}
