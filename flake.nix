{
  description = "NixOS configuration for my personal hosts.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    unstable.url = "nixpkgs/nixos-unstable";
    hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, unstable, hardware }:
    let
      overlay = final: prev: { unstable = unstable.legacyPackages.${prev.system}; };
      # Overlays-module makes "pkgs.unstable" available in configuration.nix
      overlayModule = ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay ]; });
      # To generate host configurations for all hosts.
      hostnames = builtins.attrNames (builtins.readDir ./hosts);
    in {
      nixosConfigurations = builtins.listToAttrs (builtins.map (host: {
        name = host;
        value = nixpkgs.lib.nixosSystem {
          # Simplest way to handle one host running on ARM64.
          system = if host == "sachiel" then "aarch64-linux" else "x86_64-linux";
          specialArgs.channels = { inherit nixpkgs unstable hardware; };
          modules = [ overlayModule ./hosts/${host}/configuration.nix ];
        };
      }) hostnames);
    };
}
