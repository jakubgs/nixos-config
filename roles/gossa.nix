{ lib, pkgs, config, secret, ... }:

{
  imports = [ ../services/gossa.nix ];

  options.torrent-gossa = {
    enable        = lib.mkOption { default = true; };
    port          = lib.mkOption { default = 9070; };
    dataDir       = lib.mkOption { default = "/mnt/torrent/movies"; };
    landingPrefix = lib.mkOption { default = "/gossa"; };
  };

  config = let
    cfg = config.torrent-gossa;
  in lib.mkIf cfg.enable {
    services.gossa = {
      enable = true;
      verbose = false;
      urlPrefix = "/";
      inherit (cfg) dataDir port ;
    };

    # Firewall
    networking.firewall.interfaces."eno*".allowedTCPPorts = [ 80 ];
    networking.firewall.allowedTCPPorts = [ 80 ];

    # UI available locally without VPN.
    services.nginx.virtualHosts = {
      "${config.networking.hostName}" = {
        default = true;
        basicAuthFile = secret "service/landing/htpasswd";
        locations."/" = {
          proxyPass = "http://localhost:${toString cfg.port}/";
          extraConfig = ''
            allow 127.0.0.1;
            allow 192.168.1.101;
            allow 192.168.1.102;
            allow 192.168.1.103;
            deny all;
          '';
        };
      };
    };

    # UI exposed via landing page over VPN.
    services.landing = {
      proxyServices = [{
        name = "${cfg.landingPrefix}/";
        title = "Gossa";
        value = {
          extraConfig = "rewrite ${cfg.landingPrefix}/(.*) $1 break;";
          proxyPass = "http://localhost:${toString cfg.port}/";
        };
      }];
    };

  };
}
