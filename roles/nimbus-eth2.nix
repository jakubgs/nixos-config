{ pkgs, lib, config, secret, ... }:

let
  services = config.services;
in {
  imports = [
    ../services/nimbus/beacon-node.nix
    ../services/nimbus/validator-client.nix
  ];

  options.nimbus = {
    network      = lib.mkOption { default = "mainnet"; };
    listenPort   = lib.mkOption { default = 9802; }; # WebDAV Source TLS/SSL
    discoverPort = lib.mkOption { default = 9802; }; # WebDAV Source TLS/SSL
    restPort     = lib.mkOption { default = 5052; }; # REST API
    jwtSecret    = lib.mkOption { default = secret "service/nimbus/web3-jwt-secret"; };
    bnDataDir    = lib.mkOption { default = "/var/lib/private/nimbus-beacon-node"; };
    vcDataDir    = lib.mkOption { default = "/var/lib/private/nimbus-validator-client"; };
  };

  config = let
    cfg = config.nimbus;
  in {
    # Secrets
    age.secrets."service/nimbus/web3-jwt-secret" = {
      file = ../secrets/service/nimbus/web3-jwt-secret.age;
    };

    services.nimbus-beacon-node = {
      enable = true;
      inherit (cfg) jwtSecret;
      settings = {
        data-dir = cfg.bnDataDir;
        network = cfg.network;
        tcp-port = cfg.listenPort;
        udp-port= cfg.discoverPort;
        num-threads = 0; /* 0 == auto */
        log-level = "info";
        log-format = "json";
        metrics = true;
        metrics-address = "0.0.0.0";
        metrics-port = 9100;
        rest = true;
        rest-address = "0.0.0.0";
        rest-port = cfg.restPort;
        /* Higher resource usage for small increase in rewards. */
        subscribe-all-subnets = false;
        /* Costs two slot rewards at restart if enabled. */
        doppelganger-detection = false;
        /* If Go-Ethereum is running use it. */
        web3-url =
          if services.erigon.enable then
          ["http://localhost:${builtins.toString services.erigon.settings.${"authrpc.port"}}/"]
          else if lib.hasAttr cfg.network services.geth && services.geth.${cfg.network}.enable then
          ["http://localhost:${builtins.toString services.geth.${cfg.network}.authrpc.port}/"]
          else
          [];
      } // lib.optionalAttrs (builtins.hasAttr "mev-boost" services && services.mev-boost.enable) {
        payload-builder = true;
        payload-builder-url = "http://localhost:${toString services.mev-boost.port}";
      };
    };

    # Raise priority and add required volumes.
    systemd.services.nimbus-beacon-node = {
      serviceConfig = {
        Nice = -20;
        IOSchedulingClass = "realtime";
        IOSchedulingPriority = 0;
      };
      # Wait for volume to be mounted
      after = lib.mkForce [(pkgs.lib.pathToMountUnit cfg.bnDataDir)];
    };

    services.nimbus-validator-client = {
      enable = true;
      settings = {
        data-dir = cfg.vcDataDir;
        log-level = "info";
        log-format = "json";
        beacon-node = ["http://localhost:${toString cfg.restPort}"];
        payload-builder = true;
        metrics = true;
        metrics-address = "0.0.0.0";
        metrics-port = 9101;
        /* Costs two slot rewards at restart if enabled. */
        doppelganger-detection = false;
      };
    };

    # Firewall
    networking.firewall.allowedTCPPorts = [ cfg.listenPort ];
    networking.firewall.allowedUDPPorts = [ cfg.discoverPort ];
  };
}
