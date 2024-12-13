{ lib, pkgs, config, secret, ... }:

{
  options.invidious = {
    domain   = lib.mkOption { default = "yt.${config.networking.hostName}.magi.vpn"; };
    port     = lib.mkOption { default = 9092; };
    hmac_key = lib.mkOption { default = secret "service/invidious/hmac-key"; };
  };

  config = let
    cfg = config.invidious;
  in {
    age.secrets."service/invidious/hmac-key" = {
      file = ../secrets/service/invidious/hmac-key.age;
      mode = "0644";
    };

    services.invidious = {
      enable = true;
      package = pkgs.unstable.invidious;
      inherit (cfg) port domain;
      hmacKeyFile = cfg.hmac_key;
      sig-helper = {
        enable = true;
        package = pkgs.unstable.inv-sig-helper;
      };
      database.createLocally = true;
      settings = {
        admins = ["jakubgs"];
        db.user = "invidious";
        external_port = 80;
        use_quic = true;
        channel_threads = 2;
        use_pubsub_feeds = true;
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
        "${cfg.domain}" = {
          locations."/" = {
            proxyPass = "http://localhost:${toString cfg.port}/";
          };
        };
      };
    };
  };
}
