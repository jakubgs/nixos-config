{ config, lib, pkgs, secret, ... }:

{
  options.geth = {
    devp2pPort = lib.mkOption { default = 9800; };
    jwtsecret  = lib.mkOption { default = secret "service/nimbus/web3-jwt-secret"; };
    dataDir    = lib.mkOption { default = "/var/lib/private/goethereum"; };
  };

  config = let
    cfg = config.geth;
  in {
    # Secrets
    age.secrets."service/nimbus/web3-jwt-secret" = {
      file = ../secrets/service/nimbus/web3-jwt-secret.age;
    };

    services.geth = {
      "mainnet" = {
        enable = true;
        network = null; # mainnet
        syncmode = "snap";
        maxpeers = 50;
        port = cfg.devp2pPort;
        package = pkgs.unstable.callPackage ../pkgs/go-ethereum.nix { };
        metrics = {
          enable = true;
          port = 16060;
          address = "0.0.0.0";
        };
        http = {
          enable = true;
          port = 18545;
          address = "0.0.0.0";
          apis = ["net" "eth" "admin"];
        };
        websocket = {
          enable = true;
          port = 18546;
          address = "0.0.0.0";
          apis = ["net" "eth" "admin"];
        };
        authrpc = {
          enable = true;
          port = 18551;
          address = "127.0.0.1";
          vhosts = ["localhost" "127.0.0.1"];
          jwtsecret = "$CREDENTIALS_DIRECTORY/jwtsecret";
        };
        extraArgs = [
          "--verbosity=3"
          "--log.json=true"
          "--nat=any"
          "--v5disc"
        ];
      };
    };

    # Pass JWT secret using LoadCredential.
    systemd.services.geth-mainnet = {
      serviceConfig.LoadCredential = [ "jwtsecret:${cfg.jwtsecret}" ];
    };

    /* Firewall */
    networking.firewall.allowedTCPPorts = [ cfg.devp2pPort ];
    networking.firewall.allowedUDPPorts = [ cfg.devp2pPort ];
  };
}
