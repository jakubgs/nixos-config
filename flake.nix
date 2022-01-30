{
  description = "NixOS configuration for my personal hosts.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
    unstable.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, unstable }:
    let
      unstableOverlay = final: prev: { unstable = unstable.legacyPackages.${prev.system}; };
      # Overlays-module makes "pkgs.unstable" available in configuration.nix
      unstableModule = ({ config, pkgs, ... }: { nixpkgs.overlays = [ unstableOverlay ]; });
    in {
      nixosConfigurations = let
        # To generate host configurations for all hosts.
        hostnames = builtins.attrNames (builtins.readDir ./hosts);
      in builtins.listToAttrs (builtins.map (host:
        {
          name = host;
          value = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [ unstableModule ./hosts/${host}/configuration.nix ];
          };
        }
      ) hostnames);
    };
}
