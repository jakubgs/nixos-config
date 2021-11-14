{ pkgs, ... }:

{
  imports = [
    ../services/mtr-exporter.nix
  ];

  # Firewall
  networking.firewall.allowedTCPPorts = [ 8080 ];

  services.mtr-exporter = {
    enable = true;
    target = "vectra.pl";
    interval = 30;
    package = pkgs.callPackage ../pkgs/mtr-exporter.nix { };
    mtrPackage = pkgs.mtr.overrideAttrs (old: {
      buildInputs = old.buildInputs ++ [ pkgs.jansson ];
    });
  };
}
