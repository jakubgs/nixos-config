{
  description = "NixOS configuration for my personal hosts.";

  inputs = {
    nixpkgs.url  = "nixpkgs/nixos-23.05";
    unstable.url = "nixpkgs/nixos-unstable";
    hardware.url = "github:NixOS/nixos-hardware/master";
    agenix = {
      url   = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
      inputs.home-manager.follows = "";
    };
  };

  outputs = { self, nixpkgs, unstable, hardware, agenix }:
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
      nixosConfigurations = builtins.listToAttrs (builtins.map (host: {
        name = host;
        value = nixpkgs.lib.nixosSystem {
          system = systemForHost host;
          specialArgs.channels = { inherit nixpkgs unstable hardware; };
          modules = [
            overlayModule
            agenix.nixosModules.default
            ./hosts/${host}/configuration.nix
          ];
        };
      }) hostnames);
    };
}
