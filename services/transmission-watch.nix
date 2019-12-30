#
# This service recursively monitors a watchDir with inotifywait for new *.torrent files
# and starts their downloads in matching subfolder using transmission-remote CLI tool.
#
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.transmission-watch;
  # script for watching for new *.torrent files
  inotifywait = "${pkgs.inotify-tools}/bin/inotifywait";
  transmission-remote = "${pkgs.transmission}/bin/transmission-remote";
  watch-script = pkgs.writeShellScriptBin "transmission-watch" ''
    WATCH_DIR="$1"
    DOWNLOAD_DIR="${cfg.downloadDir}"
    if [[ -z "$WATCH_DIR" ]]; then
      echo "No directory to watch specified!" >&2
      exit 1
    fi
    ${inotifywait} -q -m \
      --event=close_write \
      --format='%w %f' -r \
      --include='.*.torrent$' \
      $WATCH_DIR | {
        while IFS=' ' read -r PATH FILE; do
          FULLPATH="$PATH$FILE"
          echo "Adding torrent: $FULLPATH";
          SUBDIR="''${PATH#$WATCH_DIR}"
          ${transmission-remote} ${cfg.rpcAddr} --trash-torrent \
            --download-dir "$DOWNLOAD_DIR$SUBDIR" \
            --add "$FULLPATH"
          ${pkgs.coreutils}/bin/rm -vf "$FULLPATH"
        done 
      }
  '';
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
          default = "localhost:${toString config.services.transmission.port}";
          description = ''
            URL for the Transmission TPC port.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.transmission-watch = {
      enable = true;
      serviceConfig = {
        ExecStart = "${watch-script}/bin/transmission-watch ${cfg.watchDir}";
        Restart = "on-failure";
      };
      wantedBy = [ "multi-user.target" ];
      requires = [ "transmission.service" ];
    };
  };
}
