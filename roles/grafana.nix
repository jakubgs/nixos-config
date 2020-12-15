{ lib, config, ... }:

let
  secrets = import ../secrets.nix;

  fqdn = with config.networking; "${hostName}.${domain}";
in {
  services.grafana = {
    enable = true;
    protocol = "http";
    addr = "127.0.0.1";
    port = 3000;
    domain = fqdn;
    rootUrl = "%(protocol)s://%(domain)s:%(http_port)s/grafana/";
    extraOptions = {
      SERVER_SERVE_FROM_SUB_PATH = "true";
      AUTH_BASIC_ENABLED = "true";
    };

    security = {
      adminUser = "sochan";
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
