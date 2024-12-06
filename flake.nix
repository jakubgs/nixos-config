{
  description = "NixOS configuration for my personal hosts.";

  inputs = {
    nixpkgs.url  = "nixpkgs/nixos-24.11";
    unstable.url = "nixpkgs/nixos-unstable";
    hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-generators = {
      url = "github:nix-community/nixos-generators/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url   = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
      inputs.home-manager.follows = "";
    };
  };

  outputs = { self, nixpkgs, unstable, hardware, nixos-generators, agenix }:
    let
      overlay = final: prev: let
        unstablePkgs = import unstable { inherit (prev) system; config.allowUnfree = true; };
      in {
        unstable = unstablePkgs;
        zfsUnstable = unstablePkgs.zfsUnstable;
        erigon = import ./pkgs/erigon.nix { pkgs = prev; };
      };
      # Overlays-module makes "pkgs.unstable" available in configuration.nix
      overlayModule = ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay ]; });
      # To generate host configurations for all hosts.
      hostnames = builtins.attrNames (builtins.readDir ./hosts);
      # Some hosts are ARM64.
      systemForHost = hostname:
        if builtins.elem hostname ["leliel" "sachiel" "shamshel"] then "aarch64-linux"
        else "x86_64-linux";
    in {
      # Systems
      nixosConfigurations = builtins.listToAttrs (builtins.map (hostname: {
        name = hostname;
        value = nixpkgs.lib.nixosSystem {
          system = systemForHost hostname;
          # Allow access to all channels from inputs in modules.
          specialArgs.channels = { inherit nixpkgs unstable hardware agenix; };
          modules = [
            overlayModule
            agenix.nixosModules.default
            nixos-generators.nixosModules.all-formats
            ./hosts/${hostname}/configuration.nix
            ({...}: { networking.hostName = hostname; })
          ];
        };
      }) hostnames);
    };
}
