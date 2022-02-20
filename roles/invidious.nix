{ config, ... }:

let
  cfg = config.services.invidious;
in {
  services.invidious = {
    enable = true;
    port = 9092;
    database.createLocally = true;
    settings = {
      admins = ["jakubgs"];
      external_port = 80;
      https_only = false;
      popular_enabled = false;
    };
  };

  services.nginx = {
    virtualHosts = {
      "yt.magi.vpn" = {
        locations."/" = {
          proxyPass = "http://localhost:${toString cfg.port}/";
        };
      };
    };
  };
}
