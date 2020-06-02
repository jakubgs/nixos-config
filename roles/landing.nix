{ pkgs, config, lib, ... }:

let
  inherit (config) services;
  inherit (lib)
    hasSuffix optional flatten filter 
    catAttrs listToAttrs attrValues;

  # This list of sets represents service proxies we support.
  # To simplify merging with 'locations' we use the 
  # Nginx path as 'name' and rest of config as 'value'.
  proxiedServices = []
    ++ optional services.nginx.gitweb.enable {
      name ="/git/";
      title = "WebGit";
      value = {
        proxyPass = "http://localhost:80/gitweb/";
        extraConfig = ''
          proxy_set_header Host default;
        '';
      };
    }
    ++ optional services.syncthing.enable { 
      name ="/sync/";
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
        proxyPass = "http://${services.syncthing.guiAddress}/";
      };
    }
    ++ optional services.netdata.enable {
      name ="/netdata/";
      title = "Netdata";
      value = {
        proxyPass = "http://localhost:${toString services.netdata.config.web."default port"}/";
      };
    }
    ++ optional services.ympd.enable {
      name ="/mpd/";
      title = "YMPD";
      value = {
        proxyPass = "http://localhost:${toString services.ympd.webPort}/";
      };
    }
    ++ optional services.transmission.enable {
      name ="/torrent/";
      title = "Transmission";
      value = {
        proxyPass = "http://localhost:${toString services.transmission.port}/";
        extraConfig = ''
          proxy_pass_request_headers on;
          proxy_pass_header Authorization;
        '';
      };
    };

  landingPage = pkgs.callPackage ../templates/landing.index.nix {
    inherit proxiedServices config;
  };

  machines = [ "melchior.magi.vpn" "arael.magi.vpn" "caspair.magi.vpn" ];
  centralPage = pkgs.callPackage ../templates/central.index.nix {
    inherit machines;
  };
in {
  services.nginx = {
    enable = true;
    enableReload = true;

    virtualHosts = {
      "${config.networking.hostName}.${config.networking.domain}" = {
        basicAuthFile = "${../files/htpasswd}";
        
        locations = {
          "= /" = {
            root = pkgs.writeTextDir "index.html" landingPage;
            tryFiles = "/index.html =404";
          };
          "= /central/" = {
            root = pkgs.writeTextDir "central.html" centralPage;
            tryFiles = "/central.html =404";
          };
        } // listToAttrs proxiedServices
          # Pages combining multiple dashboards
          // listToAttrs (map (name: {
            name = "= /central${name}";
            value = {
              root = pkgs.writeTextDir "central.html" (
                pkgs.callPackage ../templates/central.index.nix { 
                  subpath = name;
                  inherit machines;
                }
              );
              tryFiles = "/central.html =404";
            };
          }) (catAttrs "name" proxiedServices));
      };
    };
  };
}
