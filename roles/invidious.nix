{ pkgs, config, ... }:

let
  domain = "yt.${config.networking.hostName}.magi.vpn";
  port = 9092;
in {
  services.invidious = {
    enable = true;
    package = pkgs.unstable.invidious;
    inherit port domain;
    database.createLocally = true;
    settings = {
      admins = ["jakubgs"];
      external_port = 80;
      https_only = false;
      popular_enabled = false;
      quality = "dash";
      quality_dash = "best";
    };
  };

  # Fix for random crashes dur to 'Invalid memory access'.
  # https://github.com/iv-org/invidious/issues/1439
  systemd.services.invidious.serviceConfig.Restart = "on-failure";

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
