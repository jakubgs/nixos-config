#
# This service recursively monitors a watchDir with inotifywait for new *.torrent files
# and starts their downloads in matching subfolder using transmission-remote CLI tool.
#
{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.usb-backup;
  pathToServiceName = path: (
    concatStringsSep "-" (drop 1 (splitString "/" path))
  );
  # Creates a map of services out of list of paths
  mkBackupServices = list: map (path: let
    serviceName = pathToServiceName path;
  in {
    name = "usb-backup-${serviceName}";
    value = {
      enable = true;
      serviceConfig = {
        ExecStart = "${pkgs.rsync}/bin/rsync --info=stats2 -ra --delete ${path} ${cfg.destination}/";
        Type = "simple";
        TimeoutStopSec = "${toString cfg.timeout}s";
      };
      unitConfig = {
        Description = "Syncing ${path} to ${cfg.destination} using rsync.";
        Requisite = [ "${serviceName}.mount" ];
        After = [ "${serviceName}.mount" ];
      };
    };
  }) list;
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

        destination = mkOption {
          type = types.str;
          default = "";
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
    systemd.services = traceVal listToAttrs (mkBackupServices cfg.sourcePaths);
  };
}
