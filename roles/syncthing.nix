{ config, lib, ... }:


let
  inherit (config) services;
  syncthingHosts = ["caspair" "melchior" "arael" "lilim"];
  notThisHost = h: h != config.networking.hostName;
  otherHosts = builtins.filter notThisHost syncthingHosts;
in {
  services.syncthing = {
    enable = true;
    user = "sochan";
    group = "sochan";
    configDir = "/home/sochan/.syncthing/config";
    dataDir = "/home/sochan/.syncthing";
    guiAddress = "127.0.0.1:8384";
    openDefaultPorts = true;

    declarative = {
      devices = lib.filterAttrs (h: v: notThisHost h) {
        caspair = { # desktop
          id = "RNHJNYU-IVWMAZT-OL667WV-Y7NOURO-WVT6IHS-MWEBAS6-SDZVQ5C-3MXHYQ5";
          addresses = [ "tcp://caspair.magi.vpn:22000" ];
        };
        melchior = { # server
          id = "42V5WFK-OBSCQW2-73PWWT6-QMGQXKR-TPTITJL-74FVKZV-MRAUJUW-YSPF5QP";
          addresses = [ "tcp://melchior.magi.vpn:22000" ];
        };
        lilim = { # laptop
          id = "IQOAEJV-4CAZQJA-5WZQWPU-WHAWIXD-RNWKSLH-I27MIAX-S4UH2EP-5YDCJQF";
          addresses = [ "tcp://lilim.magi.vpn:22000" ];
        };
        arael = { # cloud
          id = "3LSSBGT-OCETH6T-XXVBYAL-G5ULPYN-CYEA6QL-J2LYOBI-3EVTOPR-CLJBCQO";
          addresses = [ "tcp://arael.magi.vpn:22000" ];
        };
        leliel = { # rpi4b
          id = "3JHA3NU-MSQGXDA-H5EB62F-KDCCG7Y-WTJ753S-BXEIT2L-YU3XBIQ-BYLPOQJ";
          addresses = [ "tcp://leliel.magi.vpn:22000" ];
        };
        sachiel = { # rpi4b
          id = "F3AWACC-ALG2TJQ-442WT46-HJ7GGEO-BKXDCSH-5V2RMJJ-DJ42I7A-T7CHEQK";
          addresses = [ "tcp://sachiel.magi.vpn:22000" ];
        };
      };
      folders = {
        "/mnt/git"    = { id = "git";    type = "sendreceive"; devices = otherHosts; };
        "/mnt/data"   = { id = "data";   type = "sendreceive"; devices = otherHosts; };
        "/mnt/music"  = { id = "music";  type = "sendreceive"; devices = otherHosts; };
        "/mnt/photos" = { id = "photos"; type = "sendreceive"; devices = otherHosts; };
        "/mnt/mobile" = { id = "mobile"; type = "sendreceive"; devices = otherHosts; };
      };
    };
  };

  services.landing = {
    proxyServices = [
      { 
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
    ];
  };

  # Bump the inotify limit
  # https://docs.syncthing.net/users/faq.html#inotify-limits
  boot.kernel.sysctl = { "fs.inotify.max_user_watches" = "204800"; };
}
