{ pkgs, config, lib, secret, ... }:

{
  options.torrent = {
    credsFile  = lib.mkOption { default = secret "service/transmission/creds"; };
    listenPort = lib.mkOption { default = 9091; };
    torrentDir = lib.mkOption { default = "/mnt/torrent"; };
    username   = lib.mkOption { default = "jakubgs"; };
  };

  imports = [
    ../services/transmission-watch.nix
  ];

  config = let
    cfg = config.torrent;
  in {
    age.secrets."service/transmission/creds" = {
      file = ../secrets/service/transmission/creds.age;
      owner = cfg.username;
    };

    # Firewall
    networking.firewall.allowedTCPPorts = [ cfg.listenPort ];

    # Daemon
    services.transmission = {
      enable = true;
      home = cfg.torrentDir;
      user = cfg.username;
      group = cfg.username;
      credentialsFile = cfg.credsFile;
      settings = {
        download-dir = cfg.torrentDir;
        incomplete-dir-enabled = false;
        rename-partial-files = true;
        # RPC
        rpc-port = cfg.listenPort;
        rpc-bind-address = "0.0.0.0";
        rpc-whitelist-enabled = true;
        rpc-whitelist = "127.0.0.1,192.168.1.*,10.2.2.*";
        rpc-host-whitelist = "melchior.magi.vpn,melchior.magi.local";
        rpc-authentication-required = true;
        # separate service watches for torrent files to start
        watch-dir-enabled = false;
        # limits
        download-queue-size = 30;
      };
    };

    systemd.services.transmission = {
      # Wait for torrent volume to be mounted.
      unitConfig = {
        ConditionPathIsMountPoint = cfg.torrentDir;
      };
      after = lib.mkForce [
        "network.target" (pkgs.lib.pathToMountUnit cfg.torrentDir)
      ];
      wantedBy = [ (pkgs.lib.pathToMountUnit cfg.torrentDir) ];
      # Temporary for for memory leak.
      # https://github.com/transmission/transmission/issues/3494
      serviceConfig = {
        RuntimeMaxSec = "6h";
        Restart = "always";
      };
    };

    # Directory Watcher - Recursively starts torrents
    services.transmission-watch = {
      enable = true;
      watchDir = "${cfg.torrentDir}/watched";
      downloadDir = config.services.transmission.home;
      rpcCreds = config.services.transmission.credentialsFile;
    };

    services.landing = {
      proxyServices = [
        {
          name ="/torrent/";
          title = "Transmission";
          value = {
            proxyPass = "http://localhost:${toString cfg.listenPort}/";
          };
        }
      ];
    };
  };
}
