{ lib, ... }:

let
  inherit (lib) concatStringsSep splitString drop;
  newLib = {
    pathToMountUnit = path: (
      concatStringsSep "-" (drop 1 (splitString "/" path))
    ) + ".mount";
  };
in {
  # Helpers avaialble under pkgs.lib.
  nixpkgs.overlays = [
    (_: prev: { lib = prev.lib // newLib; })
  ];
}
