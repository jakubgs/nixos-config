{ pkgs, ... }:

{
  imports = [
    ../services/mtr-exporter.nix
  ];

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
