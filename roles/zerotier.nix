{ config, secret, ... }:

let
  network = secret "service/zerotier/magi";
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
  services.zerotierone.joinNetworks = [ network ];

  # Hosts Entries
  networking.hosts = {
    "10.2.2.1"  = [ "eve.magi.vpn"      ]; # router
    "10.2.2.10" = [ "melchior.magi.vpn" ]; # server
    "10.2.2.11" = [ "caspair.magi.vpn"  ]; # desktop
    "10.2.2.12" = [ "lilim.magi.vpn"    ]; # laptop
    "10.2.2.13" = [ "ramiel.magi.vpn"   ]; # phone
    "10.2.2.14" = [ "leliel.magi.vpn"   ]; # rasppi4
    "10.2.2.15" = [ "zeruel.magi.vpn"   ]; # nimbus
    "10.2.2.16" = [ "sachiel.magi.vpn"  ]; # nanopct4
    "10.2.2.17" = [ "bardiel.magi.vpn"  ]; # hetzner
    "10.2.2.18" = [ "arael.magi.vpn"    ]; # hetzner
  };

  # Search the magi domain
  networking = {
    enableIPv6 = false;
    domain = "magi.vpn";
    search = [ "magi.vpn" ];
  };
}
