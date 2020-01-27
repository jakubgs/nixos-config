{ pkgs, config, lib, ... }:

let
  proxiedServices = with lib; []
    ++ optional config.services.nginx.gitweb.enable {
      name ="/git/"; # Nginx path
      title = "WebGit";
      value = {
        extraConfig = ''
          rewrite /git/(.*) /gitweb/$1 last;
        '';
      };
    }
    ++ optional config.services.syncthing.enable { 
      name ="/sync/"; # Nginx path
      title = "SyncThing";
      value = {
        extraConfig = ''
          proxy_set_header Host localhost;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
        '';
        proxyPass = "http://${config.services.syncthing.guiAddress}/";
      };
    }
    ++ optional config.services.netdata.enable {
      name ="/netdata/"; # Nginx path
      title = "Netdata";
      value = {
        proxyPass = "http://localhost:19999/";
      };
    }
    ++ optional config.services.ympd.enable {
      name ="/mpd/"; # Nginx path
      title = "YMPD";
      value = {
        proxyPass = "http://localhost:${toString config.services.ympd.webPort}/";
      };
    };
  indexTemplate = import ../templates/landing.index.nix;
  indexPage = pkgs.callPackage indexTemplate { inherit proxiedServices; };
in {
  services.nginx = {
    enable = true;
    enableReload = true;

    virtualHosts = {
      "arael.magi.vpn" = {
        basicAuthFile = "${../files/htpasswd}";
        
        locations = {
          "/" = {
            root = "${pkgs.writeTextDir "index.html" indexPage}";
          };
        } // lib.listToAttrs proxiedServices;
      };
    };
  };
}
