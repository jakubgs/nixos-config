{
  description = "NixOS configuration for my personal hosts.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    unstable.url = "nixpkgs/nixos-unstable";
    hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, unstable, hardware }:
    let
      overlay = final: prev: {
        unstable = import unstable { inherit (prev) system; config.allowUnfree = true; };
      };
      # Overlays-module makes "pkgs.unstable" available in configuration.nix
      overlayModule = ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay ]; });
      # To generate host configurations for all hosts.
      hostnames = builtins.attrNames (builtins.readDir ./hosts);
      # Some hosts are ARM64.
      systemForHost = hostname:
        if builtins.elem hostname ["sachiel" "leliel"] then "aarch64-linux"
        else "x86_64-linux";
    in {
      nixosConfigurations = builtins.listToAttrs (builtins.map (host: {
        name = host;
        value = nixpkgs.lib.nixosSystem {
          system = systemForHost host;
          specialArgs.channels = { inherit nixpkgs unstable hardware; };
          modules = [ overlayModule ./hosts/${host}/configuration.nix ];
        };
      }) hostnames);
    };
}
