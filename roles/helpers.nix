{ lib, config, ... }:

let
  inherit (lib) concatStringsSep splitString drop;
  newLib = {
    # Shorthand for Fully Qualified Domain Name
    fqdn = with config.networking; "${hostName}.${domain}";
  };
in {
  # Helpers avaialble under pkgs.lib.
  nixpkgs.overlays = [
    (prev: final: { lib = final.lib // newLib; })
  ];
}
