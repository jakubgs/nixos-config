{ pkgs, channels, secret, ... }:

let
  devp2pPort = 9800; # WebDAV Source port
  publicIp = secret "service/geth/public-ip";

  gethPackage = pkgs.unstable.go-ethereum.geth.overrideAttrs (old: rec {
    version = "1.10.23";
    src = pkgs.fetchFromGitHub {
      owner = "ethereum";
      repo = old.pname;
      rev = "v${version}";
      sha256 = "sha256-1fEmtbHKrjuyIVrGr/vTudZ99onkNjEMvyBJt4I8KK4=";
    };
  });
in {
  /* Use service definition with AuthRPC options. */
  disabledModules = [ "services/blockchain/ethereum/geth.nix" ];
  imports = [ "${channels.unstable}/nixos/modules/services/blockchain/ethereum/geth.nix" ];

  /* Firewall */
  networking.firewall.allowedTCPPorts = [ devp2pPort ];
  networking.firewall.allowedUDPPorts = [ devp2pPort ];

  services.geth = {
    "mainnet" = {
      enable = true;
      network = null; # mainnet
      syncmode = "snap";
      maxpeers = 50;
      port = devp2pPort;
      package = gethPackage;
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
        "--nat=extip:${publicIp}"
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
