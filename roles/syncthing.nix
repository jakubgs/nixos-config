{ config, lib, pkgs, secret, ... }:


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
      default = let
        mkHostConfig = items: let
          name = builtins.elemAt items 0;
          type = builtins.elemAt items 1;
          id = builtins.elemAt items 2;
        in {
          inherit name;
          value = {
            device = { inherit id; addresses = [ "tcp://${name}.magi.vpn:22000" ]; };
            folder = { inherit type; };
          };
        };
      in listToAttrs (map mkHostConfig [
        [ "caspair"   "sendreceive" "RNHJNYU-IVWMAZT-OL667WV-Y7NOURO-WVT6IHS-MWEBAS6-SDZVQ5C-3MXHYQ5" ] # desktop
        [ "melchior"  "receiveonly" "42V5WFK-OBSCQW2-73PWWT6-QMGQXKR-TPTITJL-74FVKZV-MRAUJUW-YSPF5QP" ] # server
        [ "balthasar" "sendreceive" "HN6DXKS-ILEBPDZ-AZU5QJQ-OVLJSML-XFIIIRL-SCTRDEI-W2LFQMN-UXAOQA4" ] # laptop x390
        [ "lilim"     "sendreceive" "GGEMIJR-WYRWDE7-4QOMTZF-2QDESUK-264P4HR-3JSC7R5-662VW36-BPEOGAC" ] # laptop x1
        [ "armisael"  "sendreceive" "NLIXMAX-IUFXYNA-FY3WMWJ-FAP3BKR-SGNU2BO-ZN5EKV2-TNXR52F-DT6QYQ3" ] # laptop t480s
        [ "leliel"    "receiveonly" "3JHA3NU-MSQGXDA-H5EB62F-KDCCG7Y-WTJ753S-BXEIT2L-YU3XBIQ-BYLPOQJ" ] # rpi4b
        [ "sachiel"   "receiveonly" "4R5Z36S-6S5HBSC-2BAEZEH-HCNLXJH-GRDYZ6P-X66AFAK-RDUCRKA-PNX5YQU" ] # nanopct4
        [ "arael"     "receiveonly" "VE25Z2C-P3VDVFH-YN6E4MU-BZDO3UG-SY6S52T-IVYXMJH-V22FMIK-HMMUAQW" ] # nanopi-r6c
        [ "iruel"     "receiveonly" "2ZTE4DE-S7FRAY3-A4HFT3Y-DMJVYRZ-6HVRN3N-3OREQA6-YX3UVTT-ZGONAQU" ] # rock5b (broken)
        [ "gaghiel"   "receiveonly" "6MAGWIM-RKEUDJU-U2K4XCL-SQYNK5K-S3NUSCE-AQBEPNG-PYPNJBS-J5KPGQM" ] # rock5c
        [ "bardiel"   "receiveonly" "7XUPXBA-DQ7KGZD-VHWO4WI-F37BGFE-4F4NDXK-PD4PUX7-MIJLS6A-6CYA4Q5" ] # hetzner
        [ "ramiel"    "sendreceive" "5QRC74R-RHVPOYM-53L5HXT-HNKKG44-7ZQG5NL-KMWOYMY-KEC4AFF-PDYTRA4" ] # phone
      ]);
    };
  };

  config = let
    inherit (config) services;
    inherit (config.networking) hostName;
  in {
    age.secrets."hosts/${hostName}/syncthing/key" = {
      file = ../secrets/hosts/${hostName}/syncthing/key.age;
      owner = "jakubgs";
    };

    age.secrets."hosts/${hostName}/syncthing/cert" = {
      file = ../secrets/hosts/${hostName}/syncthing/cert.age;
      owner = "jakubgs";
    };

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
      key = secret "hosts/${hostName}/syncthing/key";
      cert = secret "hosts/${hostName}/syncthing/cert";
      guiAddress = "127.0.0.1:8384";
      overrideDevices = true;
      overrideFolders = true;

      # Use when syncing gets stuck.
      #extraFlags = ["--reset-deltas"];

      settings = let
        notThisHost = h: _: h != hostName;
        otherHosts = lib.filterAttrs notThisHost cfg.hosts;
      in {
        devices = lib.mapAttrs (_k: v: v.device) otherHosts;

        folders = let
          otherHostnames = lib.attrNames otherHosts;
          folderOpts = cfg.hosts."${hostName}".folder;
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
      after = lib.mkForce (["network.target" "agenix.service"] ++
        (map pkgs.lib.pathToMountUnit syncthingFolderNames)
      );
      unitConfig.ConditionPathIsMountPoint = syncthingFolderNames;
      # Lower priority of Syncthing service.
      serviceConfig = {
        Nice = 19;
        IOSchedulingClass = "idle";
        CPUSchedulingPolicy = "other";
        CPUWeight = 10;
        IOWeight = 10;
      };
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
