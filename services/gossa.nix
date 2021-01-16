{ config, lib, pkgs, ... }:

let
  inherit (lib) types mkEnableOption mkOption mkIf concatStringsSep optional;

  cfg = config.services.gossa;
  # script for watching for new *.torrent files
  binaryPkg = pkgs.callPackage ../pkgs/gossa.nix { };
in {
  options = {
    services = {
      gossa = {
        enable =
          mkEnableOption "Enabel a fast and simple webserver for your files.";

        dataDir = mkOption {
          type = types.str;
          default = "info";
          description = "Directory to share with gossa.";
        };

        readOnly = mkOption {
          type = types.bool;
          default = true;
          description = "Read only mode (no upload, rename, move, etc...).";
        };

        skipHidden = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to list hidden files.";
        };

        followSymlinks = mkOption {
          type = types.bool;
          default = false;
          description =
            "Follow symlinks. WARNING: symlinks allow to escape the defined path";
        };

        verbose = mkOption {
          type = types.bool;
          default = false;
          description = "Whether to list hidden files.";
        };

        port = mkOption {
          type = types.int;
          default = 9070;
          description = "Listen port for libp2p protocol.";
        };

        address = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Listen address for file manager.";
        };

        urlPrefix = mkOption {
          type = types.str;
          default = "/";
          description = "Url prefix at which gossa can be reached.";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.gossa = {
      enable = true;
      serviceConfig = {
        ExecStart = concatStringsSep " " ([
          "${binaryPkg}/bin/gossa"
          "-prefix ${cfg.urlPrefix}"
          "-p ${toString cfg.port}"
          "-h ${cfg.address}"
        ] ++ optional cfg.readOnly "-ro"
          ++ optional cfg.skipHidden "-k"
          ++ optional cfg.followSymlinks "-symlinks"
          ++ [ cfg.dataDir ]);

        Restart = "on-failure";
      };
      wantedBy = [ "multi-user.target" ];
      requires = [ "network.target" ];
    };
  };
}
