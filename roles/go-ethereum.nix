{ config, pkgs, channels, secret, ... }:

{
  /* Use service definition with AuthRPC options. */
  disabledModules = [ "services/blockchain/ethereum/geth.nix" ];
  imports = [ "${channels.unstable}/nixos/modules/services/blockchain/ethereum/geth.nix" ];

  /* Firewall */
  networking.firewall.allowedTCPPorts = [ config.services.geth.port ];
  networking.firewall.allowedUDPPorts = [ config.services.geth.port ];

  services.geth = {
    "mainnet" = {
      enable = true;
      network = null; # mainnet
      syncmode = "snap";
      maxpeers = 50;
      port = 9800; # WebDAV Source port
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
        jwtsecret = "/etc/geth/jwtsecret";
      };
      extraArgs = [
        "--verbosity=3"
        "--log.json=true"
        "--nat=extip:any"
        "--v5disc"
      ];
    };
  };

  environment.etc."geth/jwtsecret" = {
    # FIXME: Use LoadCredential instead.
    mode = "0444";
    text = secret "service/nimbus/web3-jws-secret";
  };
}
