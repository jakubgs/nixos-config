{ config, ... }:

let
  secrets = import ../secrets.nix;
in {
  # Accept license
  nixpkgs.config.allowUnfree = true;

  # Firewall
  networking.firewall = {
    # Open port for connecting to ZeroTier
    allowedTCPPorts = [ config.services.zerotierone.port ];
    # Open firewall for connections from ZeroTier
    trustedInterfaces = [ "ztbto5ttab" ];
  };

  # Daemon
  services.zerotierone.enable = true;
  services.zerotierone.joinNetworks = [ secrets.zeroTierNetwork ];

  # Hosts Entries
  networking.hosts = {
    "10.2.2.1"  = [ "melchior.magi.vpn" ]; # server
    "10.2.2.2"  = [ "arael.magi.vpn"    ]; # cloud
    "10.2.2.11" = [ "caspair.magi.vpn"  ]; # desktop
    "10.2.2.12" = [ "lilim.magi.vpn"    ]; # laptop
    "10.2.2.13" = [ "ramiel.magi.vpn"   ]; # phone
    "10.2.2.14" = [ "leliel.magi.vpn"   ]; # rasppi4
  };

  # Search the magi domain
  networking = {
    enableIPv6 = false;
    domain = "magi.vpn";
    search = [ "magi.vpn" ];
  };
}
