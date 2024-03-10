{ config, secret, ... }:

let
  networkNameFile = secret "service/zerotier/magi";
in {
  age.secrets."service/zerotier/magi" = {
    file = ../secrets/service/zerotier/magi.age;
  };

  # Accept license
  nixpkgs.config.allowUnfree = true;

  # Daemon
  services.zerotierone.enable = true;

  # Fix connection issues right after boot.
  systemd.services.zerotierone.serviceConfig.Type = "idle";

  # Workaround to use file as source of network name.
  systemd.services.zerotierone.preStart = ''
    mkdir -p /var/lib/zerotier-one/networks.d
    chmod 700 /var/lib/zerotier-one
    chown -R root:root /var/lib/zerotier-one
    touch "/var/lib/zerotier-one/networks.d/$(cat ${networkNameFile}).conf"
  '';

  # Firewall
  networking.firewall = {
    # Open port for connecting to ZeroTier
    allowedTCPPorts = [ config.services.zerotierone.port ];
    # Open firewall for connections from ZeroTier
    trustedInterfaces = [ "ztbto5ttab" ];
  };

  # Hosts Entries
  networking.hosts = {
    "10.2.2.1"  = [      "eve.magi.vpn" ]; # router
    "10.2.2.10" = [ "melchior.magi.vpn" ]; # server
    "10.2.2.11" = [  "caspair.magi.vpn" ]; # desktop
    "10.2.2.12" = [    "lilim.magi.vpn" ]; # laptop
    "10.2.2.13" = [   "ramiel.magi.vpn" ]; # phone
    "10.2.2.14" = [   "leliel.magi.vpn" ]; # rasppi4
    "10.2.2.16" = [  "sachiel.magi.vpn" ]; # nanopct4
    "10.2.2.17" = [  "bardiel.magi.vpn" ]; # hetzner
    "10.2.2.18" = [    "arael.magi.vpn" ]; # nanopir6c
    "10.2.2.19" = [   "zeruel.magi.vpn" ]; # hetzner
    "10.2.2.20" = [ "shamshel.magi.vpn" ]; # hetzner
    "10.2.2.21" = [  "israfel.magi.vpn" ]; # rock5b
  };

  # Search the magi domain
  networking = {
    enableIPv6 = false;
    domain = "magi.vpn";
    search = [ "magi.vpn" ];
  };
}
