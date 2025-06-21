{ config, lib, ... }:

{
  options.karakeep = {
    enable = lib.mkOption { default = true; };
    port   = lib.mkOption { default = 8080; };
    domain = lib.mkOption { default = "notes.magi.blue"; };
    sans   = lib.mkOption { default = [ "notes.jgs.pw" ]; };
  };

  config = let
    cfg = config.karakeep;
  in lib.mkIf cfg.enable {
    services.karakeep = {
      enable = true;
      meilisearch.enable = true;
      extraEnvironment = {
        PORT = toString cfg.port;
        DISABLE_SIGNUPS = "true";
        DISABLE_NEW_RELEASE_CHECK = "true";
      };
    };

    # LetsEncrypt
    security.acme = {
      defaults.email = "jakub@gsokolowski.pl";
      acceptTerms = true;
    };

    # Public Website
    services.nginx = {
      enable = true;
      virtualHosts = {
        "${cfg.domain}" = {
          forceSSL = true;
          enableACME = true;
          serverAliases = cfg.sans;
          locations."/" = {
            proxyPass = "http://localhost:${toString cfg.port}/";
          };
        };
      };
    };

    # Firewall
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    # Landing page link
    services.landing = {
      proxyServices = [{
        name = "/karakeep/";
        title = "Karakeep";
        value = {
          return = "302 http://${cfg.domain}/";
        };
      }];
    };
  };
}
