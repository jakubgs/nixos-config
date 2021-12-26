{ lib, config, types, ... }:

let
  inherit (lib) concatStringsSep splitString drop;
  newLib = {
  };
in {
  # Helpers avaialble under pkgs.lib.
  nixpkgs.overlays = [
    (prev: final: { lib = final.lib // newLib; })
  ];
}
