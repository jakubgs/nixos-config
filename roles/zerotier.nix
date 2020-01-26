{ config, ... }:

let
  secrets = import ../secrets.nix;
in {
  # Accept license
  nixpkgs.config.allowUnfree = true;

  # Firewall
  networking.firewall.allowedTCPPorts = [
    config.services.zerotierone.port
  ];

  # Daemon
  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [ secrets.zeroTierNetwork ];

  # Hosts Entries
  networking.hosts = {
    "10.2.2.1"  = [ "melchior.magi.vpn" ]; # server
    "10.2.2.2"  = [ "arael.magi.vpn" ];    # cloud
    "10.2.2.11" = [ "caspair.magi.vpn" ];  # desktop
    "10.2.2.12" = [ "lilim.magi.vpn" ];    # laptop
    "10.2.2.13" = [ "ramiel.magi.vpn" ];   # phone
  };

  # Search the magi domain
  networking = {
    enableIPv6 = false;
    domain = "magi.vpn";
    search = [ "magi.vpn" ];
  };
}
