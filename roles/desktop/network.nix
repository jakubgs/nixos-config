{ pkgs, ... }:

{
  # Packages
  environment.systemPackages = with pkgs; [ nftables ];

  # Enable NetworkManager
  networking.networkmanager = {
    enable = true;
    plugins = [ pkgs.networkmanager-openvpn ];
  };

  # Fix for Network Manager permission issues
  programs.dconf.enable = true;
}
