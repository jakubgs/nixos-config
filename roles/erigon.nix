{ config, pkgs, lib, secret, ... }:

{
  options.erigon = {
    devp2pPort   = lib.mkOption { default = 9800; };
    jwtSecret    = lib.mkOption { default = secret "service/nimbus/web3-jwt-secret"; };
    feeRecipient = lib.mkOption { default = secret "service/nimbus/fee-recipient"; };
    dataDir      = lib.mkOption { default = "/var/lib/private/erigon"; };
  };

  config = let
    cfg = config.erigon;
  in {
    # Secrets
    age.secrets."service/nimbus/web3-jwt-secret" = {
      file = ../secrets/service/nimbus/web3-jwt-secret.age;
    };
    age.secrets."service/nimbus/fee-recipient" = {
      file = ../secrets/service/nimbus/fee-recipient.age;
    };

    services.erigon = {
      enable = true;
      package = pkgs.callPackage ../pkgs/erigon.nix { };
      secretJwtPath = cfg.jwtSecret;
      settings = {
        "chain" = "mainnet";
        "prune" = "hrtc";
        "datadir" = cfg.dataDir;
        "miner.etherbase" = secret "service/nimbus/fee-recipient";
        "allow-insecure-unlock" = true;
        "maxpeers" = 100;
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

    # Wait for torrent volume to be mounted.
    systemd.services.erigon = {
      after = lib.mkForce [
        "network.target" (pkgs.lib.pathToMountUnit cfg.dataDir)
      ];
    };

    /* Firewall */
    networking.firewall.allowedTCPPorts = [ cfg.devp2pPort ];
    networking.firewall.allowedUDPPorts = [ cfg.devp2pPort ];
  };
}
