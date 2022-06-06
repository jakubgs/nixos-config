{ pkgs, channels, ... }:

{
  # Firewall
  networking.firewall.interfaces."zt*".allowedTCPPorts = [ 8080 ];

  services.mtr-exporter = {
    enable = true;
    target = "vectra.pl";
    interval = 30;
    address = "0.0.0.0";
  };
}
