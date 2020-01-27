{ pkgs, config, lib, ... }:

let
  inherit (lib) optional;

  proxiedServices = []
    ++ optional config.services.nginx.gitweb.enable {
      name ="/git/"; # Nginx path
      title = "WebGit";
      value = {
        proxyPass = "http://localhost:80/gitweb/";
        extraConfig = ''
          proxy_hide_header Host;
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
        proxyPass = "http://localhost:${toString config.services.netdata.config."web"."default port"}/";
      };
    }
    ++ optional config.services.ympd.enable {
      name ="/mpd/"; # Nginx path
      title = "YMPD";
      value = {
        proxyPass = "http://localhost:${toString config.services.ympd.webPort}/";
      };
    }
    ++ optional config.services.transmission.enable {
      name ="/torrent/"; # Nginx path
      title = "Transmission";
      value = {
        proxyPass = "http://localhost:${toString config.services.transmission.port}/";
        extraConfig = ''
          proxy_pass_request_headers on;
          proxy_pass_header Authorization;
        '';
      };
    };
  indexTemplate = import ../templates/landing.index.nix;
  indexPage = pkgs.callPackage indexTemplate { inherit proxiedServices config; };
in {
  services.nginx = {
    enable = true;
    enableReload = true;

    virtualHosts = {
      "arael.magi.vpn" = {
        basicAuthFile = "${../files/htpasswd}";
        
        locations = {
          "= /" = {
            root = "${pkgs.writeTextDir "index.html" indexPage}";
            tryFiles = "/index.html =400";
          };
        } // lib.listToAttrs proxiedServices;
      };
    };
  };
}
