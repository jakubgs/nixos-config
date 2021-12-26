#
# This service recursively monitors a watchDir with inotifywait for new *.torrent files
# and starts their downloads in matching subfolder using transmission-remote CLI tool.
#
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.transmission-watch;
  rpcPort = config.services.transmission.settings.rpc-port;

  # script for watching for new *.torrent files
  addTorrentScript = pkgs.substituteAll {
    src = ./transmission-add.sh;
    isExecutable = true;
    inotifytools = pkgs.inotify-tools;
    inherit (cfg) rpcAddr rpcUser rpcPass;
    inherit (pkgs) transmission coreutils;
  };

  watchScript = pkgs.substituteAll {
    src = ./transmission-watch.sh;
    isExecutable = true;
    inotifytools = pkgs.inotify-tools;
    inherit addTorrentScript;
    inherit (pkgs) coreutils;
  };
in {
  options = {
    services = {
      transmission-watch = {
        enable = mkEnableOption "Transmission directory monitoring daemon";

        watchDir = mkOption {
          type = types.str;
          default = "";
          description = ''
            Directory to monitor for *.torrent files being created.
          '';
        };

        downloadDir = mkOption {
          type = types.str;
          default = "";
          description = ''
            Directory to where the found *.torrent files should be downloaded.
          '';
        };

        rpcAddr = mkOption {
          type = types.str;
          default = "localhost:${toString rpcPort}";
          description = ''
            URL for the Transmission RPC port.
          '';
        };

        rpcUser = mkOption {
          type = types.str;
          default = "";
          description = ''
            HTTP Auth user for RPC port.
          '';
        };

        rpcPass = mkOption {
          type = types.str;
          default = "";
          description = ''
            HTTP Auth password for RPC port.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.transmission-watch = {
      enable = true;
      serviceConfig = {
        ExecStart = "${watchScript} ${cfg.watchDir} ${cfg.downloadDir}";
        Restart = "on-failure";
      };
      environment = {
        RPC_USER = cfg.rpcUser;
        RPC_PASS = cfg.rpcPass;
      };
      wantedBy = [ "multi-user.target" ];
      requires = [ "transmission.service" ];
    };
  };
}
