{ lib, config, secret, ... }:

let
  inherit (config) services;
in {
  services.grafana = {
    enable = true;

    settings = {
      server = {
        protocol = "http";
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = config.networking.fqdn;
        root_url = "%(protocol)s://%(domain)s:%(http_port)s/grafana/";
      };
      security = {
        admin_user = "jakubgs";
        admin_password = secret "service/grafana/pass";
        serve_from_sub_path = true;
        allow_embedding = true;
      };
    };

    provision = {
      enable = true;
      datasources.settings = {
        datasources = lib.optionals (config.services.prometheus.enable) [{
          name = "localhost";
          type = "prometheus";
          url = "http://localhost:${toString config.services.prometheus.port}/";
          isDefault = true;
          jsonData = { timeInterval = "10s"; };
        }];
      };
    };
  };

  services.landing = {
    proxyServices = [{
      name = "/grafana/";
      title = "Grafana";
      value = {
        proxyPass = "http://localhost:${toString services.grafana.settings.server.http_port}/";
      };
    }];
  };
}
