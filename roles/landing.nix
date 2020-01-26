{ config, lib, ... }:

{
  services.nginx = {
    enable = true;
    enableReload = true;

    virtualHosts = {
      "arael.magi.vpn" = {
        basicAuthFile = "${../files/htpasswd}";
        
        locations = {
          # Main Landing Page
          "/" = {
            root = "${../files/landing}";
          };

          # SyncThing Web GUI
          "/sync/" = lib.optionalAttrs config.services.syncthing.enable {
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_read_timeout 600s;
              proxy_send_timeout 600s;
            '';
            proxyPass = "http://${config.services.syncthing.guiAddress}/";
          };

          # Git WebGUI
          "/git/" = lib.optionalAttrs config.services.nginx.gitweb.enable {
            extraConfig = ''
              rewrite /git/(.*) /gitweb/$1 last;
            '';
          };
        };
      };
    };
  };
}
