{ config, lib, pkgs, ... }:

let
  inherit (lib) types mkEnableOption mkOption mkIf concatStringsSep;
  cfg = config.services.mtr-exporter;
in {
  options = {
    services = {
      mtr-exporter = {
        enable =
          mkEnableOption "Enabel a fast and simple webserver for your files.";

        target = mkOption {
          type = types.str;
          description = "Target to check using MTR.";
        };

        interval = mkOption {
          type = types.int;
          default = 60;
          description = "Interval between MTR checks in seconds.";
        };

        port = mkOption {
          type = types.int;
          default = 8080;
          description = "Listen port for MTR exporter.";
        };

        address = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Listen address for MTR exporter.";
        };

        mtrFlags = mkOption {
          type = with types; listOf str;
          default = [];
          example = ["-G1"];
          description = "Additional flags to pass to MTR.";
        };

        package = mkOption {
          type = types.package;
          default = pkgs.mtr-exporter;
          description = "Overridable MTR exporter package.";
        };

        mtrPackage = mkOption {
          type = types.package;
          default = pkgs.mtr;
          description = "Overridable MTR package.";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mtr-exporter = {
      enable = true;
      serviceConfig = {
        ExecStart = concatStringsSep " " ([
          "${cfg.package}/bin/mtr-exporter"
          "-mtr ${cfg.mtrPackage}/bin/mtr"
          "-schedule '@every ${toString cfg.interval}s'"
          "-bind ${cfg.address}:${toString cfg.port}"
        ] ++ [ "--" ] ++ cfg.mtrFlags ++ [ cfg.target ]);

        Restart = "on-failure";
      };
      wantedBy = [ "multi-user.target" ];
      requires = [ "network.target" ];
    };
  };
}
