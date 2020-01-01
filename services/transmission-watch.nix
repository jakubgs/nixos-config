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
    RPC_ADDR="${cfg.rpcAddr}"
    ${optionalString (cfg.rpcUser != "") "RPC_AUTH=\"--auth ${cfg.rpcUser}:${cfg.rpcPass}\""}
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
          SUBDIR="''${PATH#$WATCH_DIR/}"
          echo "Subfolder: $DOWNLOAD_DIR$SUBDIR"
          ${transmission-remote} $RPC_ADDR $RPC_AUTH \
            --trash-torrent \
            --add "$FULLPATH" \
            --download-dir "$DOWNLOAD_DIR$SUBDIR"
          if [[ $? -eq 0 ]]; then
            ${pkgs.coreutils}/bin/rm -vf "$FULLPATH"
          else
            ${pkgs.coreutils}/bin/mv "$FULLPATH" "$FULLPATH.failed"
            echo "Failed to add torrent!"
          fi
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
        ExecStart = "${watch-script}/bin/transmission-watch ${cfg.watchDir}";
        Restart = "on-failure";
      };
      wantedBy = [ "multi-user.target" ];
      requires = [ "transmission.service" ];
    };
  };
}
