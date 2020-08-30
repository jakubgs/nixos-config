{ config, lib, ... }:


let
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
          id = "3WCZ4ZA-XPW2B2T-7BE2FP2-Z7TO63K-IOFJD4V-QTS6W7R-5UNDPAJ-DQJOSAU";
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
      };
      folders = {
        "/mnt/git"    = { id = "git";    type = "sendreceive"; devices = otherHosts; };
        "/mnt/data"   = { id = "data";   type = "sendreceive"; devices = otherHosts; };
        "/mnt/music"  = { id = "music";  type = "sendreceive"; devices = otherHosts; };
        "/mnt/mobile" = { id = "mobile"; type = "sendreceive"; devices = otherHosts; };
      };
    };
  };

  # Bump the inotify limit
  # https://docs.syncthing.net/users/faq.html#inotify-limits
  boot.kernel.sysctl = { "fs.inotify.max_user_watches" = "204800"; };
}
