{ config, ... }:

let
  domain = "yt.${config.networking.hostName}.magi.vpn";
  port = 9092;
in {
  services.invidious = {
    enable = true;
    inherit port domain;
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
      "${domain}" = {
        locations."/" = {
          proxyPass = "http://localhost:${toString port}/";
        };
      };
    };
  };
}
