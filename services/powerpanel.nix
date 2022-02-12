{ config, lib, pkgs, ... }:

let
  inherit (lib) types isBool mapAttrsToList literalExpression
    mkEnableOption mkOption mkIf concatStringsSep optional;

  cfg = config.services.powerpanel;
  # script for watching for new *.torrent files
  binaryPkg = pkgs.callPackage ../pkgs/powerpanel.nix { };

  # formatting
  formatBool = value: assert isBool value; if value then "yes" else "no";
  formatConfig = key: value: "${key} = " +
    (if isBool value then formatBool value
    else toString value);

  # Scripts
  powerFailScriptFile = pkgs.writeScript "powerfail-handler.sh" cfg.powerFailScript;
  lowBatteryScriptFile = pkgs.writeScript "lowbatt-handler.sh" cfg.lowBatteryScript;
in {
  options = {
    services.powerpanel = {
      enable =
        mkEnableOption "Enabel a fast and simple webserver for your files.";

      powerFailScript = mkOption {
        type = types.lines;
        default = "wall 'Power failure!'";
        description = ''
          Contents of script called when power failure occurs.
        '';
      };

      lowBatteryScript = mkOption {
        type = types.lines;
        default = "wall 'Battery power low!'";
        description = ''
          Contents of script called when power failure occurs.
        '';
      };

      settings = mkOption {
        type = with types; attrsOf (oneOf [ path bool int str ]);
        default = {
          powerfail-delay = 60;
          powerfail-active = true;
          powerfail-cmd-path = powerFailScriptFile;
          powerfail-duration = 0;
          powerfail-shutdown = true;
          runtime-threshold = 300;
          lowbatt-threshold = 35;
          lowbatt-active = true;
          lowbatt-cmd-path = lowBatteryScriptFile;
          lowbatt-duration = 0;
          lowbatt-shutdown = true;
          enable-alarm = true;
          shutdown-sustain = 600;
          turn-ups-off = true;
          ups-polling-rate = 3;
          ups-retry-rate = 10;
          hibernate = false;
        };
        description = ''
          PowerPanel configuration in /etc/pwrstatd.conf.
          <link xlink:href="https://dl4jz3rbrsfum.cloudfront.net/documents/CyberPower_UM_PPL.pdf"/>
        '';
        example = literalExpression ''
          {
            powerfail-delay = 600;
            turn-ups-off = false;
            enable-alarm = false;
          }
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.powerpanel = {
      enable = true;
      serviceConfig = {
        ExecStart = "${binaryPkg}/bin/pwrstatd";
        Restart = "on-failure";
      };
      wantedBy = [ "multi-user.target" ];
      requires = [ "network.target" ];
      restartTriggers = [
        config.environment.etc."pwrstatd.conf".source
      ];
    };

    # Config path is hardcoded in the binary.
    environment.etc."pwrstatd.conf" = {
      text = concatStringsSep "\n" (mapAttrsToList formatConfig cfg.settings);
      mode = "0444";
    };
  };
}
