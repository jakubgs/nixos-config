{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkOption mkEnableOption types escapeShellArgs;
  cfg = config.services.meteo-exporter;
in {
  options.services.meteo-exporter = {
    enable = mkEnableOption "Meteo exporter service";

    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ../pkgs/meteo-exporter { };
      description = "Package providing the meteo-exporter executable.";
    };

    listenAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address on which the exporter listens.";
    };

    port = mkOption {
      type = types.port;
      default = 9109;
      description = "TCP port on which the exporter listens.";
    };

    passwordFile = mkOption {
      type = types.path;
      description = "File containing the weather station update password.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.meteo-exporter = {
      description = "Meteo Prometheus exporter";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        ExecStart = escapeShellArgs [
          "${cfg.package}/bin/meteo-exporter"
          "--listen-address=${cfg.listenAddress}"
          "--port=${toString cfg.port}"
          "--password-file=%d/password"
        ];
        LoadCredential = [ "password:${toString cfg.passwordFile}" ];
        DynamicUser = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        Restart = "on-failure";
      };
    };
  };
}
