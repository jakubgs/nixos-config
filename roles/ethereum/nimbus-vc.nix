{ lib, config, ... }:

let
  srv = config.services;
  cfg = config.nimbusVC;

  inherit (lib) mkOption;
in {
  options.nimbusVC = {
    dataDir     = mkOption { default = "/var/lib/private/nimbus-validator-client"; };
    metricsPort = mkOption { default = 9102; }; # Metrics API
  };

  config = {
    services.nimbus-validator-client = {
      enable = true;
      settings = {
        log-level = "info";
        log-format = "json";
        data-dir = cfg.dataDir;
        payload-builder = true;
        metrics = true;
        metrics-address = "0.0.0.0";
        metrics-port = cfg.metricsPort;
        /* Costs two slot rewards at restart if enabled. */
        doppelganger-detection = false;
        beacon-node = if srv.nimbus-beacon-node.enable
          then ["http://localhost:${toString srv.nimbus-beacon-node.settings.rest-port}"]
          else [];
      };
    };
  };
}
