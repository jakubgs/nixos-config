{ lib, pkgs, config, secret, ... }:

{
  options.invidious = {
    domain    = lib.mkOption { default = "${config.networking.hostName}.magi.vpn"; };
    port      = lib.mkOption { default = 9092; };
    proxyPort = lib.mkOption { default = 9095; };
    hmac_key  = lib.mkOption { default = secret "service/invidious/hmac-key"; };
  };

  config = let
    cfg = config.invidious;
  in {
    age.secrets."service/invidious/hmac-key" = {
      file = ../secrets/service/invidious/hmac-key.age;
      mode = "0644";
    };

    age.secrets."service/landing/server.key" = {
      file = ../secrets/service/landing/server.key.age;
      owner = "nginx";
    };

    services.invidious = {
      enable = true;
      package = pkgs.unstable.invidious;
      inherit (cfg) port domain;
      hmacKeyFile = cfg.hmac_key;
      sig-helper = {
        enable = false; # Currently broken.
        package = pkgs.unstable.inv-sig-helper;
      };
      database.createLocally = true;
      settings = {
        admins = ["jakubgs"];
        db.user = "invidious";
        external_port = 80;
        channel_refresh_interval = "60m";
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

    # Necessary due to Invidious not being able to run under a sub-path.
    services.nginx = {
      virtualHosts = {
        "invidious.${cfg.domain}" = {
          listen = [ { port = cfg.proxyPort; addr = "0.0.0.0"; ssl = true; } ];
          serverName = "${cfg.domain}";
          serverAliases = [ "invidious.${cfg.domain}" ];
          forceSSL = true;
          sslCertificate     = ../secrets/service/landing/server.crt;
          sslCertificateKey = secret "service/landing/server.key";
          extraConfig = ''
            ssl_client_certificate ${../secrets/service/landing/ca.crt};
            ssl_crl                ${../secrets/service/landing/crl.pem};
            ssl_verify_client      on;
          '';
          locations = {
            "/" = {
              proxyPass = "http://localhost:${toString cfg.port}/";
            };
          };
        };
      };
    };

    services.landing = {
      proxyServices = [{
        name = "/invidious/";
        title = "Invidious";
        value = {
          return = "302 https://${cfg.domain}:${toString cfg.proxyPort}/";
        };
      }];
    };
  };
}
