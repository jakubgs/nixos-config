#
# This service recursively monitors a watchDir with inotifywait for new *.torrent files
# and starts their downloads in matching subfolder using transmission-remote CLI tool.
#
{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.usb-backup;
  isMountPoint = path: hasAttr path config.fileSystems;
  pathToServiceName = path: (
    concatStringsSep "-" (drop 1 (splitString "/" path))
  );
  # Creates a map of services out of list of paths
  mkBackupServices = paths: map (path: let
    serviceName = pathToServiceName path;
    # if not a mount point we can't wait for .mount service
    afterReq = optionals (isMountPoint path) [ "${serviceName}.mount" ];
  in {
    name = "usb-backup-${serviceName}";
    value = {
      enable = true;
      description = "Syncing ${path} to ${cfg.destination} using rsync.";
      serviceConfig = {
        ExecStart = "${pkgs.rsync}/bin/rsync --info=stats2 -ra --delete ${path} ${cfg.destination}/";
        Type = "simple";
        TimeoutStopSec = "${toString cfg.timeout}s";
      };
      requisite = afterReq;
      after = afterReq;
    };
  }) paths;
  # Creates a map of services out of list of paths
  mkBackupTimers = paths: map (path: let
    serviceName = pathToServiceName path;
  in {
    name = "usb-backup-${serviceName}";
    value = {
      enable = true;
      description = "Timer for syncing ${path} to ${cfg.destination} using rsync.";
      timerConfig = {
        Unit = "usb-backup-${serviceName}.service";
        OnCalendar = cfg.frequency;
        Persistent = true;
      };
      wantedBy = [ "basic.target" ];
    };
  }) paths;
in {
  options = {
    services = {
      usb-backup = {
        enable = mkEnableOption "Service for rsyncing folders to destination.";

        timeout = mkOption {
          type = types.int;
          default = 600;
          description = ''
            Time in seconds before rsync command times out.
          '';
        };

        frequency = mkOption {
          type = types.str;
          default = "daily";
          description = ''
            Frequency in the systemd OnCalendar format.
          '';
        };

        destination = mkOption {
          type = types.str;
          default = "daily";
          description = ''
            Path to which rsync will copy the given directory.
          '';
        };

        sourcePaths = mkOption {
          type = types.listOf types.str;
          default = [];
          description = ''
            List of paths which should be rsynced to the destination.
          '';
        };
      };
    };
  };

  # Defines multiple services for multiple sourcePaths
  config = mkIf cfg.enable {
    systemd.services = listToAttrs (mkBackupServices cfg.sourcePaths);
    systemd.timers = listToAttrs (mkBackupTimers cfg.sourcePaths);
  };
}
