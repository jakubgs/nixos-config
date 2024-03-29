{ config, lib, pkgs, ... }:


{
  options.syncthing = {
    hosts = lib.mkOption {
      default = {
        caspair = { # desktop
          id = "RNHJNYU-IVWMAZT-OL667WV-Y7NOURO-WVT6IHS-MWEBAS6-SDZVQ5C-3MXHYQ5";
          addresses = [ "tcp://caspair.magi.vpn:22000" ];
          autoAcceptFolders = true;
        };
        melchior = { # server
          id = "42V5WFK-OBSCQW2-73PWWT6-QMGQXKR-TPTITJL-74FVKZV-MRAUJUW-YSPF5QP";
          addresses = [ "tcp://melchior.magi.vpn:22000" ];
          autoAcceptFolders = true;
        };
        lilim = { # laptop
          id = "GGEMIJR-WYRWDE7-4QOMTZF-2QDESUK-264P4HR-3JSC7R5-662VW36-BPEOGAC";
          addresses = [ "tcp://lilim.magi.vpn:22000" ];
          autoAcceptFolders = true;
        };
        leliel = { # rpi4b
          id = "3JHA3NU-MSQGXDA-H5EB62F-KDCCG7Y-WTJ753S-BXEIT2L-YU3XBIQ-BYLPOQJ";
          addresses = [ "tcp://leliel.magi.vpn:22000" ];
          autoAcceptFolders = true;
        };
        sachiel = { # nanopct4
          id = "4R5Z36S-6S5HBSC-2BAEZEH-HCNLXJH-GRDYZ6P-X66AFAK-RDUCRKA-PNX5YQU";
          addresses = [ "tcp://sachiel.magi.vpn:22000" ];
          autoAcceptFolders = true;
        };
        arael = { # nanopi-r6c
          id = "HOBTQ6M-WYSYZM3-SVXACFZ-VOLJRR3-XCIWSZB-FLPYML4-F4BE35Q-3NIF4AB";
          addresses = [ "tcp://arael.magi.vpn:22000" ];
          autoAcceptFolders = true;
        };
        bardiel = { # hetzner
          id = "7XUPXBA-DQ7KGZD-VHWO4WI-F37BGFE-4F4NDXK-PD4PUX7-MIJLS6A-6CYA4Q5";
          addresses = [ "tcp://bardiel.magi.vpn:22000" ];
          autoAcceptFolders = true;
        };
        ramiel = { # phone
          id = "2UQXCXB-LZHCGVM-PFOL3NW-GRU57X7-R4IHVR7-SS2WDSP-TX5DFSG-YCNG7QJ";
          addresses = [ "tcp://ramiel.magi.vpn:22000" ];
          autoAcceptFolders = true;
        };
      };
    };
  };

  config = let
    notThisHost = h: h != config.networking.hostName;
    otherHosts = builtins.filter notThisHost (lib.attrNames config.syncthing.hosts);
    inherit (config) services;
  in {
    # Firewall
    networking.firewall.interfaces."zt*".allowedTCPPorts = [ 22000 ];
    networking.firewall.interfaces."zt*".allowedUDPPorts = [ 22000 21027 ];

    # Service
    services.syncthing = {
      enable = true;
      user = "jakubgs";
      group = "jakubgs";
      configDir = "/home/jakubgs/.syncthing/config";
      dataDir = "/home/jakubgs/.syncthing";
      guiAddress = "127.0.0.1:8384";

      # Use when syncing gets stuck.
      #extraFlags = ["--reset-deltas"];

      settings = {
        devices = lib.filterAttrs (h: _: notThisHost h) config.syncthing.hosts;

        folders = {
          "/mnt/git"    = { id = "git";    type = "sendreceive"; devices = otherHosts; };
          "/mnt/data"   = { id = "data";   type = "sendreceive"; devices = otherHosts; };
          "/mnt/music"  = { id = "music";  type = "sendreceive"; devices = otherHosts; };
          "/mnt/photos" = { id = "photos"; type = "sendreceive"; devices = otherHosts; };
          "/mnt/mobile" = { id = "mobile"; type = "sendreceive"; devices = otherHosts; };
        };
      };
    };

    # Wait for volumes to be mounted.
    systemd.services.syncthing = let
      syncthingFolderNames = lib.attrNames services.syncthing.settings.folders;
    in {
      after = lib.mkForce (["network.target"] ++
        (map pkgs.lib.pathToMountUnit syncthingFolderNames)
      );
      unitConfig.ConditionPathIsMountPoint = syncthingFolderNames;
    };

    services.landing = {
      proxyServices = [
        {
          name ="/sync/";
          title = "Syncthing";
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
  };
}
