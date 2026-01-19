{
  description = "NixOS configuration for my personal hosts.";

  inputs = {
    nixpkgs.url  = "nixpkgs/nixos-25.11";
    unstable.url = "nixpkgs/nixos-unstable";
    hardware.url = "github:NixOS/nixos-hardware/master";
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

  outputs = { self, nixpkgs, unstable, hardware, disko, nixos-generators, agenix }:
    let
      # To generate host configurations for all hosts.
      hostnames = builtins.attrNames (builtins.readDir ./hosts);
      # Some hosts are ARM64.
      systemForHost = hostname:
        if builtins.elem hostname ["arael" "gaghiel" "leliel" "sachiel" "shamshel"]
          then "aarch64-linux" else "x86_64-linux";
    in {
      # Systems
      nixosConfigurations = builtins.listToAttrs (builtins.map (hostname: {
        name = hostname;
        value = nixpkgs.lib.nixosSystem {
          system = systemForHost hostname;
          # Allow access to all channels from inputs in modules.
          specialArgs = {
            unstablePkgs = import unstable {
              system = systemForHost hostname;
              config.allowUnfree = true;
            };
            channels = { inherit nixpkgs unstable hardware agenix; };
          };
          modules = [
            disko.nixosModules.disko
            agenix.nixosModules.default
            nixos-generators.nixosModules.all-formats
            ./hosts/${hostname}/configuration.nix
            ({...}: { networking.hostName = hostname; })
          ];
        };
      }) hostnames);
    };
}
