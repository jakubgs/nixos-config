{ lib, config, secret, fqdn, ... }:

let
  inherit (config) services;
in {
  services.grafana = {
    enable = true;
    protocol = "http";
    addr = "127.0.0.1";
    port = 3000;
    domain = config.networking.fqdn;
    rootUrl = "%(protocol)s://%(domain)s:%(http_port)s/grafana/";
    extraOptions = {
      SERVER_SERVE_FROM_SUB_PATH = "true";
      SECURITY_ALLOW_EMBEDDING = "true";
      AUTH_BASIC_ENABLED = "true";
    };

    security = {
      adminUser = "jakubgs";
      adminPassword = secret "service/grafana/pass";
    };

    provision = {
      enable = true;
      datasources = lib.optionals (config.services.prometheus.enable) [{
        name = "localhost";
        type = "prometheus";
        url = "http://localhost:${toString config.services.prometheus.port}/";
        isDefault = true;
        jsonData = { timeInterval = "10s"; };
      }];
    };
  };

  services.landing = {
    proxyServices = [{
      name = "/grafana/";
      title = "Grafana";
      value = {
        proxyPass = "http://localhost:${toString services.grafana.port}/";
      };
    }];
  };
}
