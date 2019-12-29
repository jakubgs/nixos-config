{ config, lib, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  # Accept license
  nixpkgs.config.allowUnfree = true;

  # Clients
  #environment.systemPackages = with pkgs; [ ];

  # Firewall
  networking.firewall.allowedTCPPorts = [ config.services.zerotierone.port ];

  # Daemon
  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [ secrets.zeroTierNetwork ];

  # Hosts Entries
  networking.hosts = {
    "10.2.2.1"  = [ "melchior.magi" ]; # server
    "10.2.2.2"  = [ "arael.magi" ];    # cloud
    "10.2.2.11" = [ "caspair.magi" ];  # desktop
    "10.2.2.12" = [ "lilim.magi" ];    # laptop
    "10.2.2.13" = [ "ramiel.magi" ];   # phone
  };
}
