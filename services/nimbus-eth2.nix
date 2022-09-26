{ config, lib, pkgs, ... }:

let
  inherit (lib)
    types mkEnableOption mkOption mkIf length
    escapeShellArgs literalExpression toUpper
    boolToString optionalString optionalAttrs;

  cfg = config.services.nimbus-eth2;
in {
  options = {
    services = {
      nimbus-eth2 = {
        enable = mkEnableOption "Nimbus Eth2 Beacon Node service.";

        package = mkOption {
          type = types.package;
          default = pkgs.callPackage ../pkgs/nimbus-eth2.nix { };
          defaultText = literalExpression "pkgs.go-ethereum.geth";
          description = lib.mdDoc "Package to use as Go Ethereum node.";
        };

        service = {
          user = mkOption {
            type = types.str;
            default = "nimbus";
            description = "Username for Nimbus Eth2 service.";
          };

          group = mkOption {
            type = types.str;
            default = "nimbus";
            description = "Group name for Nimbus Eth2 service.";
          };
        };

        dataDir = mkOption {
          type = types.str;
          default = "";
          description = "Directory for Nimbus Eth2 blockchain data.";
        };

        network = mkOption {
          type = types.str;
          default = "mainnet";
          description = "Name of Eth2 network to connect to.";
        };

        graffiti = mkOption {
          type = types.str;
          default = "Nimbus-Eth2";
          description = "Name of Eth2 network to connect to.";
        };

        log = {
          level = mkOption {
            type = types.str;
            default = "info";
            description = "Logging level for the node.";
          };

          format = mkOption {
            type = types.str;
            default = "auto";
            description = "Logging formatting (auto, colors, nocolors, json).";
          };
        };

        threadsNumber = mkOption {
          type = types.int;
          default = 1;
          description = "Number of worker threads. Use 0 to detect CPU cores.";
        };

        publicIp = mkOption {
          type = types.str;
          default = "";
          description = "Public IP address of the node to advertise.";
        };

        web3Url = mkOption {
          type = types.str;
          default = "";
          description = "URL for the Web3 RPC endpoint.";
        };

        jwtSecret = mkOption {
          type = types.str;
          default = "";
          description = "Path of JWT secret for Auth RPC endpoint.";
        };

        subAllSubnets = mkOption {
          type = types.bool;
          default = false;
          description = "Subscribe to all attestation subnet topics.";
        };

        doppelganger = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Protection against slashing due to double-voting.
            Means you will miss two attestations when restarting.
          '';
        };

        suggestedFeeRecipient = mkOption {
          type = types.str;
          default = "";
          description = ''
            Wallet address where transaction fee tips - priority fees,
            unburnt portion of gas fees - will be sent.
          '';
        };

        listenPort = mkOption {
          type = types.int;
          default = 9000;
          description = "Listen port for libp2p protocol.";
        };

        discoverPort = mkOption {
          type = types.int;
          default = 9000;
          description = "Listen port for libp2p protocol.";
        };

        metrics = {
          enable = lib.mkEnableOption "Nimbus Eth2 metrics endpoint";
          address = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = "Metrics address for beacon node.";
          };
          port = mkOption {
            type = types.int;
            default = 9100;
            description = "Metrics port for beacon node.";
          };
        };

        rest = {
          enable = lib.mkEnableOption "Nimbus Eth2 REST API";
          address = mkOption {
            type = types.str;
            default = "127.0.0.1";
            description = "Listening address of the REST API server";
          };

          port = mkOption {
            type = types.int;
            default = 5052;
            description = "Port for the REST API server";
          };
        };

        extraArgs = mkOption {
          type = types.listOf types.str;
          description = lib.mdDoc "Additional arguments passed to node.";
          default = [];
        };
      };
    };
  };

  config = mkIf cfg.enable {
    users.users = optionalAttrs (cfg.service.user == "nimbus") {
      nimbus = {
        group = cfg.service.group;
        home = cfg.dataDir;
        description = "Nimbus Eth2 service user";
        isSystemUser = true;
      };
    };

    users.groups = optionalAttrs (cfg.service.user == "nimbus") {
      nimbus = { };
    };

    systemd.services.nimbus-eth2 = {
      enable = true;
      serviceConfig = {
        User = cfg.service.user;
        Group = cfg.service.group;

        ExecStart = ''
          ${cfg.package}/bin/nimbus_beacon_node \
            --network=${cfg.network} \
            --graffiti=${cfg.graffiti} \
            --data-dir=${cfg.dataDir} \
            --web3-url=${cfg.web3Url} \
            --jwt-secret=${cfg.jwtSecret} \
            --nat=extip:${cfg.publicIp} \
            --log-level=${toUpper cfg.log.level} \
            --log-format=${cfg.log.format} \
            --num-threads=${toString cfg.threadsNumber} \
            --tcp-port=${toString cfg.listenPort} \
            --udp-port=${toString cfg.discoverPort} \
            --rest=${boolToString cfg.rest.enable} ${optionalString cfg.rest.enable ''--rest-address=${cfg.rest.address} --rest-port=${toString cfg.rest.port} ''}\
            --metrics=${boolToString cfg.metrics.enable} ${optionalString cfg.metrics.enable ''--metrics-address=${cfg.metrics.address} --metrics-port=${toString cfg.metrics.port} ''}\
            --subscribe-all-subnets=${boolToString cfg.subAllSubnets} \
            --doppelganger-detection=${boolToString cfg.doppelganger} \
            --suggested-fee-recipient=${cfg.suggestedFeeRecipient} ${optionalString (length cfg.extraArgs > 0) "\\"}
            ${escapeShellArgs cfg.extraArgs}
        '';
        Restart = "on-failure";
      };
      wantedBy = [ "multi-user.target" ];
      requires = [ "network.target" ];
    };
  };
}
