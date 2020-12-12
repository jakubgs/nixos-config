{ modulesPath, pkgs, ... }:

# This image can be built using nixos-generate.
# https://github.com/nix-community/nixos-generators
{
  imports = [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
    ../../roles/security.nix
    ../../roles/base.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/netdata.nix
    ../../roles/zerotier.nix
    ../../roles/landing.nix
  ];

  # SWAP due to low memory
  swapDevices = [
    { device = "/swapfile"; size = 2048; }
  ];

  # Upgrade kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable ZFS support
  boot.supportedFilesystems = [ "zfs" ];
  # Scrub to find errors
  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
    pools = [ "DATA" ];
  };

  networking = {
    hostName = "zeruel";
    hostId = "b9a1a20b";
    interfaces.eth0.useDHCP = true;
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "pl";
  };

  # Lower priority of builds to not Disturb other processes
  nix.daemonNiceLevel = 19;
  nix.daemonIONiceLevel = 7;

  # Set your time zone.
  time.timeZone = "Europe/Frankfurt";

  # Determines the NixOS release with which your system is to be compatible
  # You should change this only after NixOS release notes say you should.
  system.stateVersion = "20.09";
}
