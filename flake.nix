{
  description = "NixOS configuration for my personal hosts.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.11";
    unstable.url = "nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, unstable }:
    let
      overlay = final: prev: { unstable = unstable.legacyPackages.${prev.system}; };
      # Overlays-module makes "pkgs.unstable" available in configuration.nix
      overlayModule = ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay ]; });
    in {
      nixosConfigurations = let
        # To generate host configurations for all hosts.
        hostnames = builtins.attrNames (builtins.readDir ./hosts);
      in builtins.listToAttrs (builtins.map (host:
        {
          name = host;
          value = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs.channels = { inherit nixpkgs unstable; };
            modules = [ overlayModule ./hosts/${host}/configuration.nix ];
          };
        }
      ) hostnames);
    };
}
