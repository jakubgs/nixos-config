{ pkgs, config, lib, secret, ... }:

let
  listenPort = 9091;
  torrentDir = "/mnt/torrent";
  username = "jakubgs";
  password = secret "service/transmission/pass";
in {
  imports = [
    ../services/transmission-watch.nix
  ];

  # Firewall
  networking.firewall.allowedTCPPorts = [ listenPort ];

  # Daemon
  services.transmission = {
    enable = true;
    home = torrentDir;
    user = username;
    group = username;
    settings = {
      download-dir = torrentDir;
      incomplete-dir-enabled = false;
      rename-partial-files = true;
      # RPC
      rpc-port = listenPort;
      rpc-bind-address = "0.0.0.0";
      rpc-whitelist-enabled = true;
      rpc-whitelist = "127.0.0.1,192.168.1.*,10.2.2.*";
      rpc-host-whitelist = "melchior.magi.vpn,melchior.magi.local";
      rpc-authentication-required = true;
      rpc-username = username;
      rpc-password = password;
      # separate service watches for torrent files to start
      watch-dir-enabled = false;
      # limits
      download-queue-size = 30;
    };
  };

  systemd.services.transmission = {
    # Wait for torrent volume to be mounted.
    after = lib.mkForce [
      "network.target" (pkgs.lib.pathToService torrentDir)
    ];
    # Temporary for for memory leak.
    # https://github.com/transmission/transmission/issues/3494
    serviceConfig.RuntimeMaxSec = "6h";
  };

  # Directory Watcher - Recursively starts torrents
  services.transmission-watch = {
    enable = true;
    watchDir = "${torrentDir}/watched";
    downloadDir = torrentDir;
    rpcUser = username;
    rpcPass = password;
  };

  services.landing = {
    proxyServices = [
      {
        name ="/torrent/";
        title = "Transmission";
        value = {
          proxyPass = "http://localhost:${toString listenPort}/";
        };
      }
    ];
  };
}
