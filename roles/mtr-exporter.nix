{ pkgs, unstable, ... }:

{
  imports = [
    <nixos-unstable/nixos/modules/services/networking/mtr-exporter.nix>
  ];

  nixpkgs.overlays = [
    (new: prev: { mtr-exporter = unstable.mtr-exporter; })
  ];

  # Firewall
  networking.firewall.interfaces."zt*".allowedTCPPorts = [ 8080 ];

  services.mtr-exporter = {
    enable = true;
    target = "vectra.pl";
    interval = 30;
    address = "0.0.0.0";
  };
}
