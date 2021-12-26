{ lib, config, types, ... }:

let
  inherit (lib) concatStringsSep splitString drop;
  newLib = {
    pathToService = path: (
      concatStringsSep "-" (drop 1 (splitString "/" path))
    ) + ".service";
  };
in {
  # Helpers avaialble under pkgs.lib.
  nixpkgs.overlays = [
    (prev: final: { lib = final.lib // newLib; })
  ];
}
