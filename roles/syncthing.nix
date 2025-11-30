{ config, lib, pkgs, ... }:


let
  cfg = config.syncthing;

  inherit (lib) filter elem attrNames listToAttrs;
in {
  options.syncthing = {
    folders = lib.mkOption {
      description = "Default folders to sync if mounted.";
      default = ["git" "data" "music" "photos" "mobile"];
    };
    hosts = lib.mkOption {
      description = "List of hosts with Syncthing and their IDs.";
      default = {
        caspair = { # desktop
          device = {
            id = "RNHJNYU-IVWMAZT-OL667WV-Y7NOURO-WVT6IHS-MWEBAS6-SDZVQ5C-3MXHYQ5";
            addresses = [ "tcp://caspair.magi.vpn:22000" ];
          };
          folder = { type = "sendreceive"; };
        };
        melchior = { # server
          device = {
            id = "42V5WFK-OBSCQW2-73PWWT6-QMGQXKR-TPTITJL-74FVKZV-MRAUJUW-YSPF5QP";
            addresses = [ "tcp://melchior.magi.vpn:22000" ];
          };
          folder = { type= "receiveonly"; };
        };
        balthasar = { # laptop
          device = {
            id = "HN6DXKS-ILEBPDZ-AZU5QJQ-OVLJSML-XFIIIRL-SCTRDEI-W2LFQMN-UXAOQA4";
            addresses = [ "tcp://balthasar.magi.vpn:22000" ];
          };
          folder = { type= "sendreceive"; };
        };
        lilim = { # laptop
          device = {
            id = "GGEMIJR-WYRWDE7-4QOMTZF-2QDESUK-264P4HR-3JSC7R5-662VW36-BPEOGAC";
            addresses = [ "tcp://lilim.magi.vpn:22000" ];
          };
          folder = { type= "sendreceive"; };
        };
        leliel = { # rpi4b
          device = {
            id = "3JHA3NU-MSQGXDA-H5EB62F-KDCCG7Y-WTJ753S-BXEIT2L-YU3XBIQ-BYLPOQJ";
            addresses = [ "tcp://leliel.magi.vpn:22000" ];
          };
          folder = { type= "receiveonly"; };
        };
        sachiel = { # nanopct4
          device = {
            id = "4R5Z36S-6S5HBSC-2BAEZEH-HCNLXJH-GRDYZ6P-X66AFAK-RDUCRKA-PNX5YQU";
            addresses = [ "tcp://sachiel.magi.vpn:22000" ];
          };
          folder = { type= "receiveonly"; };
        };
        arael = { # nanopi-r6c
          device = {
            id = "HOBTQ6M-WYSYZM3-SVXACFZ-VOLJRR3-XCIWSZB-FLPYML4-F4BE35Q-3NIF4AB";
            addresses = [ "tcp://arael.magi.vpn:22000" ];
          };
          folder = { type= "receiveonly"; };
        };
        iruel = { # rock5b
          device = {
            id = "2ZTE4DE-S7FRAY3-A4HFT3Y-DMJVYRZ-6HVRN3N-3OREQA6-YX3UVTT-ZGONAQU";
            addresses = [ "tcp://iruel.magi.vpn:22000" ];
          };
          folder = { type= "receiveonly"; };
        };
        bardiel = { # hetzner
          device = {
            id = "7XUPXBA-DQ7KGZD-VHWO4WI-F37BGFE-4F4NDXK-PD4PUX7-MIJLS6A-6CYA4Q5";
            addresses = [ "tcp://bardiel.magi.vpn:22000" ];
          };
          folder = { type= "receiveonly"; };
        };
        ramiel = { # phone
          device = {
            id = "5QRC74R-RHVPOYM-53L5HXT-HNKKG44-7ZQG5NL-KMWOYMY-KEC4AFF-PDYTRA4";
            addresses = [ "tcp://ramiel.magi.vpn:22000" ];
          };
          folder = { type= "sendreceive"; };
        };
      };
    };
  };

  config = let
    hostname = config.networking.hostName;
    notThisHost = h: _: h != hostname;
    otherHosts = lib.filterAttrs notThisHost cfg.hosts;
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
      overrideDevices = true;
      overrideFolders = true;

      # Use when syncing gets stuck.
      #extraFlags = ["--reset-deltas"];

      settings = {
        devices = lib.mapAttrs (k: v: v.device) otherHosts;

        folders = let
          otherHostnames = lib.attrNames otherHosts;
          folderOpts = cfg.hosts."${hostname}".folder;
          # Generated from locally mounted folders.
          mountedFolders = filter (n: elem (baseNameOf n) cfg.folders) (attrNames config.fileSystems);
          folderToConfig = (name: {
            inherit name;
            value = { id = baseNameOf name; devices = otherHostnames; } // folderOpts;
          });
        in listToAttrs (map folderToConfig mountedFolders);
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
