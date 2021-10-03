{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.protonmail-bridge;
in {
  options = {
    services = {
      protonmail-bridge = {
        enable = mkEnableOption "Transmission directory monitoring daemon";

        nonInteractive = mkOption {
          type = types.boolean;
          default = true;
          description = ''
            Start Bridge entirely noninteractively (default: false)
          '';
        };

        logLevel = mkOption {
          type = types.str;
          default = "info";
          description = ''
            Set the log level (one of panic, fatal, error, warn, info, debug)
          '';
        };

        package = mkOption {
          default = pkgs.protonmail-bridge;
          defaultText = "pkgs.rxvt-unicode";
          description = ''
            Package to install. Usually pkgs.rxvt-unicode.
          '';
          type = types.package;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.protonmail-bridge = {
      enable = true;
      description = "ProtonMail bridge service";
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 5;
        ExecStart = ''
          ${cfg.package}/bin/protonmail-bridge \
            --log-level ${cfg.logLevel} \
            --no-window
        '';
      };
      path = [ pkgs.gnome.gnome-keyring ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];
    };
  };
}
