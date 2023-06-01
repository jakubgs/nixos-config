{ pkgs, ... }:

{
  # Packages
  environment.systemPackages = with pkgs; [ nftables ];

  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # Fix for Network Manager permission issues
  programs.dconf.enable = true;
}
