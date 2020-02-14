{ config, lib, ... }:


let
  syncthingHosts = ["caspair" "melchior" "arael"];
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
        caspair = {
          id = "EVNUYJP-TPGQVZM-NI7IWRB-WL24QEM-G4IIHTV-WE3HLMV-O5LW7IM-CFWDRAI";
          addresses = [ "tcp://caspair.magi.vpn:22000" ];
        };
        melchior = {
          id = "42V5WFK-OBSCQW2-73PWWT6-QMGQXKR-TPTITJL-74FVKZV-MRAUJUW-YSPF5QP";
          addresses = [ "tcp://melchior.magi.vpn:22000" ];
        };
        arael = {
          id = "3LSSBGT-OCETH6T-XXVBYAL-G5ULPYN-CYEA6QL-J2LYOBI-3EVTOPR-CLJBCQO";
          addresses = [ "tcp://arael.magi.vpn:22000" ];
        };
      };
      folders = {
        "/mnt/git"   = { id = "git";   type = "sendreceive"; devices = otherHosts; };
        "/mnt/data"  = { id = "data";  type = "sendreceive"; devices = otherHosts; };
        "/mnt/music" = { id = "music"; type = "sendreceive"; devices = otherHosts; };
      };
    };
  };

  # Bump the inotify limit
  # https://docs.syncthing.net/users/faq.html#inotify-limits
  boot.kernel.sysctl = { "fs.inotify.max_user_watches" = "204800"; };
}
