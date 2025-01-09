{ config, lib, pkgs, ... }:

let
  inherit (lib)
    types mkEnableOption mkOption mkIf
    concatStringsSep optional literalExpression;

  cfg = config.services.mev-boost;
in {
  options = {
    services = {
      mev-boost = {
        enable =
          mkEnableOption "Enable service for sourcing high-MEV blocks from a builder marketplace";

        package = mkOption {
          type = types.package;
          default = pkgs.mev-boost;
          defaultText = literalExpression "pkgs.mev-boost";
          description = lib.mdDoc "Package to use for MEV-Boost service.";
        };

        network = mkOption {
          type = types.enum [ "mainnet" "holesky" "sepolia" ];
          default = "mainnet";
          description = "Ethereum network. Available: mainnet, holesky, sepolia";
        };


        logLevel = mkOption {
          type = types.str;
          default = "info";
          description = "Log level. Available: trace, debug, info, warning, error, fatal, panic";
        };

        logJson = mkOption {
          type = types.bool;
          default = true;
          description = "Print logs in JSON format.";
        };

        address = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Listen address for use by beacon node.";
        };

        port = mkOption {
          type = types.int;
          default = 18550;
          description = "Listen port for use by beacon node.";
        };

        relays = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "List of Ethereum builder relays.";
        };

        extraArgs = mkOption {
          type = types.listOf types.str;
          description = lib.mdDoc "Additional arguments passed to service.";
          default = [];
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mev-boost = {
      enable = true;
      serviceConfig = {
        DynamicUser = true;
        Restart = "on-failure";
        ExecStart = concatStringsSep " " ([
          "${cfg.package}/bin/mev-boost"
          "--${cfg.network}"
          "--loglevel=${cfg.logLevel}"
          "--addr=${cfg.address}:${toString cfg.port}"
          "--relays=${concatStringsSep "," cfg.relays}"
        ] ++ optional cfg.logJson "--json"
          ++ cfg.extraArgs);

        # Hardening measures
        PrivateTmp = "true";
        ProtectSystem = "full";
        NoNewPrivileges = "true";
        PrivateDevices = "true";
        MemoryDenyWriteExecute = "true";
      };
      wantedBy = [ "multi-user.target" ];
      requires = [ "network.target" ];
      after = [ "network.target" ];
    };
  };
}
