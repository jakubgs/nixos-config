{ lib, config, ... }:

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

  # Make helper function vailable in module arguments.
  # WARNING: Can cause infinite recursion errors!
  _module.args.secret = name: config.age.secrets."${name}".path;
}
