{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption mkOption mkIf
    types filterAttrs optionalAttrs
    escapeShellArgs literalExpression;

  cfg = config.services.nimbus-validator-client;

  toml = pkgs.formats.toml { };
  removeNull = k: v: v != null;
  cleanSettings = filterAttrs removeNull cfg.settings;
  configFile = toml.generate "nimbus-validator-client.toml" cleanSettings;
in {
  options = {
    services = {
      nimbus-validator-client = {
        enable = mkEnableOption "Nimbus Eth2 Validator Client service.";

        package = mkOption {
          type = types.package;
          default = pkgs.callPackage ../../pkgs/nimbus-eth2.nix { };
          defaultText = literalExpression "pkgs.nimbus-eth2";
          description = lib.mdDoc "Package to use as Go Ethereum node.";
        };

        extraArgs = mkOption {
          type = types.listOf types.str;
          description = lib.mdDoc "Additional arguments passed to node.";
          default = [];
        };

        settings = lib.mkOption {
          description = "TOML config file settings for Nimbus Eth2 validator client.";
          default = {};
          type = lib.types.submodule {
            freeformType = toml.type;
            options = {
              data-dir = mkOption {
                type = types.path;
                default = "/var/lib/private/nimbus-validator-client";
                description = "Directory for Nimbus Eth2 blockchain data.";
              };

              era-dir = mkOption {
                type = types.nullOr types.path;
                default = null;
                description = "Directory for Nimbus Eth2 ERA files.";
              };

              validators-dir = mkOption {
                type = types.nullOr types.path;
                default = null;
                description = "A directory containing validator keystores.";
              };

              secrets-dir = mkOption {
                type = types.nullOr types.path;
                default = null;
                description = "A directory containing validator keystore passwords.";
              };

              graffiti = mkOption {
                type = types.str;
                default = "nimbus-validator-client";
                description = "Name of Eth2 network to connect to.";
              };

              log-level = mkOption {
                type = types.str;
                default = "info";
                description = "Logging level for the node.";
              };

              log-format = mkOption {
                type = types.str;
                default = "auto";
                description = "Logging formatting (auto, colors, nocolors, json).";
              };

              doppelganger-detection = mkOption {
                type = types.bool;
                default = true;
                description = ''
                  Protection against slashing due to double-voting.
                  Means you will miss two attestations when restarting.
                '';
              };

              beacon-node = mkOption {
                type = types.listOf types.str;
                default = [];
                description = "URL addresses to one or more beacon node HTTP REST APIs [=$defaultBeaconNodeUri].";
              };

              payload-builder = mkOption {
                type = types.nullOr types.bool;
                default = null;
                description = "Enable usage of beacon node with external payload builder (BETA) [=false].";
              };

              web3-signer-url = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Remote Web3Signer URL that will be used as a source of validators.";
              };

              suggested-fee-recipient = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Suggested fee recipient.";
              };

              metrics = lib.mkEnableOption "Nimbus Eth2 metrics endpoint";

              metrics-address = mkOption {
                type = types.str;
                default = "127.0.0.1";
                description = "Metrics address for beacon node.";
              };

              metrics-port = mkOption {
                type = types.int;
                default = 9100;
                description = "Metrics port for beacon node.";
              };

              keymanager = lib.mkEnableOption "Enable the REST keymanager API.";

              keymanager-port = mkOption {
                type = types.port;
                default = 5052;
                description = "Listening port for the REST keymanager API.";
              };

              keymanager-address = mkOption {
                type = types.str;
                default = "127.0.0.1";
                description = "Listening address for the REST keymanager API.";
              };

              keymanager-allow-origin = mkOption {
                type = types.str;
                default = "localhost,127.0.0.1";
                description = "Limit the access to the Keymanager API to a particular hostname.";
              };

              keymanager-token-file = mkOption {
                type = types.nullOr types.path;
                default = null;
                description = "A file specifying the authorizition token required for accessing the keymanager API.";
              };
            };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    environment.etc."nimbus/validator-client.toml".source = configFile;

    systemd.services.nimbus-validator-client = {
      enable = true;
      serviceConfig = {
        DynamicUser = true;

        # Hardening measures
        PrivateTmp = "true";
        ProtectSystem = "full";
        NoNewPrivileges = "true";
        PrivateDevices = "true";
        StateDirectory = "nimbus-validator-client";
        WorkingDirectory = "%S/nimbus-validator-client";
        MemoryDenyWriteExecute = "true";

        Restart = "on-failure";
        ExecStart = ''
          ${cfg.package}/bin/nimbus_validator_client --config-file=${configFile} ${escapeShellArgs cfg.extraArgs}
        '';
      };
      wantedBy = [ "multi-user.target" ];
      requires = [ "network.target" ];
    };
  };
}
