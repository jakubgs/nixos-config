{ lib, config, ... }:

let
  secrets = import ../secrets.nix;
in {
  services.grafana = {
    enable = true;
    protocol = "http";
    addr = "127.0.0.1";
    port = 3000;

    security = {
      adminUser = "admin";
      adminPassword = secrets.grafanaAdminPassword;
    };

    provision = {
      enable = true;
      datasources =
        lib.optionals (config.services.prometheus.enable) [{
          name = "localhost";
          type = "prometheus";
          url = "http://localhost:${toString config.services.prometheus.port}/";
          isDefault = true;
      }];
    };
  };
}
