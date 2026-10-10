{ config, lib, pkgs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption types escapeShellArgs;
  cfg = config.services.meteo-dashboard;
  outputFile = "${cfg.outputDirectory}/index.html";
  # Temp file to avoid Nginx serving partially generated
  temporaryFile = "${outputFile}.tmp";
in {
  options.services.meteo-dashboard = {
    enable = mkEnableOption "Static Meteo dashboard generator";

    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ../pkgs/meteo-dashboard { };
      description = "Package providing the meteo-dashboard executable.";
    };

    prometheusUrl = mkOption {
      type = types.str;
      default = "http://localhost:9090";
      description = "Prometheus base URL used to fetch weather history.";
    };

    station = mkOption {
      type = types.str;
      example = "PWS-123ABC";
      description = "Weather station identifier.";
    };

    frequency = mkOption {
      type = types.str;
      default = "hourly";
      description = "systemd OnCalendar expression for dashboard generation.";
    };

    outputDirectory = mkOption {
      type = types.str;
      default = "/var/www/meteo-dashboard";
      description = "Directory containing the generated page for nginx.";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.outputDirectory} 0755 nginx nginx -"
    ];

    systemd.services.meteo-dashboard = {
      description = "Generate static Meteo dashboard";
      after = [ "network-online.target" "prometheus.service" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        User = "nginx";
        Group = "nginx";
        ExecStart = escapeShellArgs [
          "${cfg.package}/bin/meteo-dashboard"
          "--prometheus-url=${cfg.prometheusUrl}"
          "--station=${cfg.station}"
          "--output=${temporaryFile}"
        ];
        ExecStartPost = escapeShellArgs [
          "${pkgs.coreutils}/bin/mv"
          temporaryFile
          outputFile
        ];
        ReadWritePaths = [ cfg.outputDirectory ];
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
      };
    };

    systemd.timers.meteo-dashboard = {
      description = "Meteo dashboard generation timer";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.frequency;
        Persistent = true;
        Unit = "meteo-dashboard.service";
      };
    };
  };
}
