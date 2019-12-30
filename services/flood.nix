{ config, lib, pkgs, ... }:

with lib;

let
  flood = pkgs.callPackage ../pkgs/flood.nix { };
  cfg   = config.services.flood;
  bash  = "/run/current-system/sw/bin/bash";
  chmod = "/run/current-system/sw/bin/chmod";
in {
  options = {
    services = {
      flood = {
        enable = mkEnableOption "Flood rtorrent Web UI daemon";

        workDir = mkOption {
          type = types.str;
          default = "/var/run/flood";
          description = ''
            Directory for rtorrent working files.
          '';
        };

        user = mkOption {
          type = types.str;
          default = "flood";
          description = ''
            User account under which Flood runs.
          '';
        };

        group = mkOption {
          type = types.str;
          default = "flood";
          description = ''
            Group under which Flood runs.
          '';
        };

        listenPort = mkOption {
          type = types.int;
          default = 3000;
          description = ''
            Port to use for listening.
          '';
        };
        
        rtorrentSocket = mkOption {
          type = types.str;
          default = "";
          description = ''
            Path to the SCGI socket of rTorrent.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.flood = {
      enable = true;
      preStart = ''
        mkdir -m 0700 -p ${cfg.workDir}
        chown ${cfg.user}:${cfg.group} ${cfg.workDir}
      '';
      serviceConfig = {
        User      = cfg.user;
        Group     = cfg.group;
        ExecStart = "${pkgs.nodejs-12_x}/bin/node ${flood}/server/bin/www";
        KillMode  = "none";
        Restart   = "on-failure";
        WorkingDirectory = cfg.workDir;
      };
      environment = {
        FLOOD_SERVER_PORT = toString cfg.listenPort;
        RTORRENT_SCGI_SOCKET = cfg.rtorrentSocket;
      };
      wantedBy = [ "default.target" ];
      after    = [ "network.target" ];
    };

    environment.systemPackages = [ flood ];

    users.users = mkIf (cfg.user == "flood") {
      flood = {
        group = cfg.group;
        home = cfg.workDir;
        description = "flood Daemon user";
      };
    };

    users.groups = mkIf (cfg.group == "flood") {
      flood = {};
    };
  };
}
