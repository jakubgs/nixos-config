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
    inherit (cfg) rpcAddr rpcCreds;
    inherit (pkgs) transmission coreutils jq;
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

        serviceGroup = mkOption {
          type = types.str;
          default = "jakubgs";
          description = ''
            Group to run the watch service as.
          '';
        };

        rpcAddr = mkOption {
          type = types.str;
          default = "localhost:${toString rpcPort}";
          description = ''
            URL for the Transmission RPC port.
          '';
        };

        rpcCreds = mkOption {
          type = types.str;
          default = "";
          description = ''
            Path to JSON file with RPC credentials.
            Same format as credentialsFile in transmission config.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.transmission-watch = {
      enable = true;
      serviceConfig = {
        DynamicUser = true;
        Group = cfg.serviceGroup;
        ExecStart = "${watchScript} ${cfg.watchDir} ${cfg.downloadDir}";
        Restart = "on-failure";
      };
      environment = {
        RPC_CREDS = cfg.rpcCreds;
      };
      wantedBy = [ "multi-user.target" ];
      requires = [ "transmission.service" ];
    };
  };
}
