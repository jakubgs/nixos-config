{ config, pkgs, lib, secret, ... }:

let
  devp2pPort = 9800; # WebDAV Source port
  publicIp = secret "hosts/${config.networking.hostName}/ip";
in {
  services.erigon = {
    enable = true;
    #package = pkgs.unstable.callPackage ../pkgs/erigon.nix { };
    secretJwtPath = "/etc/erigon/jwtsecret";
    settings = {
      "chain" = "mainnet";
      "mine" = true;
      "allow-insecure-unlock" = true;
      "maxpeers" = 100;
      "nat" = "extip:${publicIp}";
      "datadir" = "/mnt/erigon";
      "log.console.json" = true;
      "log.console.verbosity" = "info";
      # DevP2P
      "port" = devp2pPort;
      "p2p.allowed-ports" = [devp2pPort (devp2pPort+1)];
      # RPC
      "http.addr" = "localhost";
      "http.port" = 18545;
      # AuthRPC / Engine API
      "authrpc.addr" = "localhost";
      "authrpc.port" = 18551;
      "authrpc.vhosts" = "TODO";
      # Metrics
      "metrics" = true;
      "metrics.addr" = "0.0.0.0";
      "metrics.port" = 16060;
    };
  };

  # Custom user
  users.groups.erigon.gid = 500;
  users.users.erigon = {
    uid = 500;
    group = "erigon";
    isSystemUser = true;
  };
  systemd.services.erigon = {
    # Wait for torrent volume to be mounted.
    after = lib.mkForce [
      "network.target" (
        pkgs.lib.pathToMountUnit config.services.erigon.settings.datadir
      )
    ];
    serviceConfig = {
      User = "erigon";
      DynamicUser = lib.mkForce false;
    };
  };

  # Secrets
  environment.etc."erigon/jwtsecret" = {
    mode = "0440";
    user = config.systemd.services.erigon.serviceConfig.User;
    text = secret "service/nimbus/web3-jws-secret";
  };

  /* Firewall */
  networking.firewall.allowedTCPPorts = [ devp2pPort ];
  networking.firewall.allowedUDPPorts = [ devp2pPort ];

}
