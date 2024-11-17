{ config, lib, pkgs, ... }:

let
  inherit (lib)
    types mkEnableOption mkOption mkIf
    concatStringsSep optional literalExpression;
  inherit (pkgs.lib) pathToMountUnit;

  cfg = config.services.gossa;
in {
  options = {
    services = {
      gossa = {
        enable =
          mkEnableOption "Enabel a fast and simple webserver for your files.";

        package = mkOption {
          type = types.package;
          default = pkgs.gossa;
          defaultText = literalExpression "pkgs.gossa";
          description = lib.mdDoc "Package to use for Gossa service.";
        };

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
          description = "Print verbose logs.";
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
          "${cfg.package}/bin/gossa"
          "-prefix ${cfg.urlPrefix}"
          "-p ${toString cfg.port}"
          "-h ${cfg.address}"
        ] ++ optional cfg.verbose "-verb"
          ++ optional cfg.readOnly "-ro"
          ++ optional cfg.skipHidden "-k"
          ++ optional cfg.followSymlinks "-symlinks"
          ++ [ cfg.dataDir ]);

        Restart = "on-failure";
      };
      wantedBy = [ "multi-user.target" ];
      requires = [ "network.target" ];
      after = [ "network.target" (pathToMountUnit cfg.dataDir) ];
      unitConfig.ConditionPathIsMountPoint = cfg.dataDir;
    };
  };
}
