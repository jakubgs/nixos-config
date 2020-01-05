{ config, lib, pkgs, ... }:

let
  secrets = import ../secrets.nix;
in {
  # Firewall
  networking.firewall.allowedTCPPorts = [
    config.vars.ports.nextcloud
  ];

  # Proxy
  services.nginx.enable = true;
  services.nginx.virtualHosts = {
    ${config.services.nextcloud.hostName} = {
      listen = [{
        addr = "0.0.0.0";
        port = config.vars.ports.nextcloud;
      }];
    };
  };

  # Daemon
  services.nextcloud.enable = true;
  services.nextcloud.home = "/mnt/data/nextcloud";
  services.nextcloud.hostName = "melchior.magi.local";
  services.nextcloud.config.extraTrustedDomains = [ "melchior.magi" ];
  services.nextcloud.config.adminuser = "sochan";
  services.nextcloud.config.adminpass = secrets.nextCloudPass;
  services.nextcloud.nginx.enable = true;
}
