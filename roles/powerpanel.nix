{ config, pkgs, ... }:

{
  imports = [ ../services/powerpanel.nix ];

  environment.systemPackages = [
    (pkgs.callPackage ../pkgs/powerpanel.nix { })
  ];

  services.powerpanel.enable = true;
}
