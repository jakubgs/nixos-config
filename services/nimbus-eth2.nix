{ config, lib, pkgs, ... }:

let
  inherit (lib) types mkEnableOption mkOption mkIf toUpper boolToString;

  cfg = config.services.nimbus-eth2;
  # script for watching for new *.torrent files
  binaryPkg = pkgs.callPackage ../pkgs/nimbus-eth2.nix { };
in {
  options = {
    services = {
      nimbus-eth2 = {
        enable = mkEnableOption "Nimbus Eth2 Beacon Node service.";

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

        logLevel = mkOption {
          type = types.str;
          default = "info";
          description = "Logging level for the node.";
        };

        logFormat = mkOption {
          type = types.str;
          default = "auto";
          description = "Logging formatting (auto, colors, nocolors, json).";
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

        metricsPort = mkOption {
          type = types.int;
          default = 9100;
          description = "Metrics port for beacon node.";
        };

        rpcAddr = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "RPC JSON REST endpoint listen address.";
        };

        rpcPort = mkOption {
          type = types.int;
          default = 8545;
          description = "RPC JSON REST endpoint listen port.";
        };

        restAddr = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Listening address of the REST API server";
        };

        restPort = mkOption {
          type = types.int;
          default = 5052;
          description = "Port for the REST API server";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.nimbus-eth2 = {
      enable = true;
      serviceConfig = {
        ExecStart = ''
          ${binaryPkg}/bin/nimbus_beacon_node \
            --network=${cfg.network} \
            --graffiti=${cfg.graffiti} \
            --data-dir=${cfg.dataDir} \
            --web3-url=${cfg.web3Url} \
            --jwt-secret=${cfg.jwtSecret} \
            --nat=extip:${cfg.publicIp} \
            --log-level=${toUpper cfg.logLevel} \
            --log-format=${cfg.logFormat} \
            --num-threads=${toString cfg.threadsNumber} \
            --tcp-port=${toString cfg.listenPort} \
            --udp-port=${toString cfg.discoverPort} \
            --rpc \
            --rpc-address=${cfg.rpcAddr} \
            --rpc-port=${toString cfg.rpcPort} \
            --rest \
            --rest-address=${cfg.restAddr} \
            --rest-port=${toString cfg.restPort} \
            --metrics \
            --metrics-address=0.0.0.0 \
            --metrics-port=${toString cfg.metricsPort} \
            --subscribe-all-subnets=${boolToString cfg.subAllSubnets} \
            --doppelganger-detection=${boolToString cfg.doppelganger}
        '';
        Restart = "on-failure";
      };
      wantedBy = [ "multi-user.target" ];
      requires = [ "network.target" ];
    };
  };
}
