{ lib, config, secret, ... }:

let
  cfg = config.nimbusEL;

  inherit (lib) mkOption;
in {
  options.nimbusEL = {
    network     = mkOption { default = "mainnet"; };
    listenPort  = mkOption { default = 30303; }; # LibP2P TCP
    httpPort    = mkOption { default = 8545; }; # RPC API
    enginePort  = mkOption { default = 8551; }; # AuthRPC API
    metricsPort = mkOption { default = 9100; }; # Metrics API
    jwtSecret   = mkOption { default = secret "service/nimbus/web3-jwt-secret"; };
    dataDir     = mkOption { default = "/var/lib/private/nimbus-execution-client"; };
  };

  config = {
    # Secrets
    age.secrets."service/nimbus/web3-jwt-secret" = {
      file = ../../secrets/service/nimbus/web3-jwt-secret.age;
    };

    services.nimbus-execution-client = {
      enable = true;
      settings = {
        log-level = "info";
        log-format = "json";
        data-dir = cfg.dataDir;
        network = [cfg.network];
        prune = true;
        jwt-secret = cfg.jwtSecret;
        tcp-port = cfg.listenPort;
        udp-port = cfg.listenPort;
        metrics = true;
        metrics-address = "0.0.0.0";
        metrics-port = cfg.metricsPort;
        http-address = "127.0.0.1";
        http-port = cfg.httpPort;
        rpc = true;
        rpc-api = ["admin" "eth"];
        engine-api = true;
        engine-api-address = "127.0.0.1";
        engine-api-port = cfg.enginePort;
      };
    };

    # Firewall
    networking.firewall = {
      allowedTCPPorts = [ cfg.listenPort ];
      allowedUDPPorts = [ cfg.listenPort ];
    };
  };
}
