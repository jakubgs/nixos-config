{ pkgs, lib, config, secret, ... }:

let
  srv = config.services;
  cfg = config.nimbusBN;

  inherit (lib) mkOption optionals optionalAttrs mkForce;
in {
  options.nimbusBN = {
    network     = mkOption { default = "mainnet"; };
    listenPort  = mkOption { default = 9802; }; # WebDAV Source TLS/SSL
    restPort    = mkOption { default = 5052; }; # REST API
    metricsPort = mkOption { default = 9101; }; # Metrics API
    jwtSecret   = mkOption { default = secret "service/nimbus/web3-jwt-secret"; };
    dataDir     = mkOption { default = "/var/lib/private/nimbus-beacon-node"; };
  };

  config = {
    # Secrets
    age.secrets."service/nimbus/web3-jwt-secret" = {
      file = ../../secrets/service/nimbus/web3-jwt-secret.age;
    };

    services.nimbus-beacon-node = {
      enable = true;
      settings = {
        log-level = "info";
        log-format = "json";
        data-dir = cfg.dataDir;
        network = cfg.network;
        tcp-port = cfg.listenPort;
        udp-port= cfg.listenPort;
        jwt-secret = cfg.jwtSecret;
        metrics = true;
        metrics-address = "0.0.0.0";
        metrics-port = cfg.metricsPort;
        rest = true;
        rest-address = "0.0.0.0";
        rest-port = cfg.restPort;
        /* Costs two slot rewards at restart if enabled. */
        doppelganger-detection = false;
        /* Use whatever EL is available on the host. */
        web3-url = let
          mkUrl = port: ["http://localhost:${toString port}/"];
        in   optionals srv.nimbus-execution-client.enable        (mkUrl srv.nimbus-execution-client.settings.engine-api-port)
          ++ optionals srv.erigon.enable                         (mkUrl srv.erigon.settings."authrpc.port")
          ++ optionals (srv.geth.${cfg.network}.enable or false) (mkUrl srv.geth.${cfg.network}.authrpc.port);
      } // optionalAttrs (srv.mev-boost.enable or false) {
        payload-builder = true;
        payload-builder-url = "http://localhost:${toString srv.mev-boost.port}";
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
      after = mkForce [(pkgs.lib.pathToMountUnit cfg.dataDir)];
    };

    # Firewall
    networking.firewall = {
      allowedTCPPorts = [ cfg.listenPort ];
      allowedUDPPorts = [ cfg.listenPort ];
    };
  };
}
