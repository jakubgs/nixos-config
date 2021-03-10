{ pkgs, ... }:

let
  unstablePkgs = import <nixos-unstable> { };
in {
  # Enable clipboard manager
  services.clipmenu = {
    enable = true;
    package = unstablePkgs.clipmenu;
  };
}
