{ config, lib, pkgs, secret, ... }:

# Temporary validator workshop nodes.
{
  disabledModules = [
     "services/blockchain/ethereum/geth.nix"
  ];
  imports = [
    ../services/geth.nix
  ];

  options.nimbus = {
    devp2pPort = lib.mkOption { default = 9800; };
    jwtsecret  = lib.mkOption { default = secret "service/nimbus/web3-jwt-secret"; };
  };

  config = let
    cfg = config.nimbus;
  in {
    services.geth = {
      "holesky" = {
        enable = true;
        network = "holesky";
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
    systemd.services.geth-holesky = {
      serviceConfig.LoadCredential = [ "jwtsecret:${cfg.jwtsecret}" ];
    };

    /* Firewall */
    networking.firewall.allowedTCPPorts = [ cfg.devp2pPort ];
    networking.firewall.allowedUDPPorts = [ cfg.devp2pPort ];
  };
}
