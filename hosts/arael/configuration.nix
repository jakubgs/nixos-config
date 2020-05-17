{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/security.nix
    ../../roles/base.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/netdata.nix
    ../../roles/zerotier.nix
    ../../roles/syncthing.nix
    ../../roles/gitweb.nix
    ../../roles/netdata.nix
    ../../roles/landing.nix
  ];

  # SWAP due to low memory
  swapDevices = [
    { device = "/swapfile"; size = 4096; }
  ];

  # No need to tinker with AWS bootloader
  boot.loader.grub.device = "nodev";

  # Upgrade kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # Modules for sensors
  boot.kernelModules = [ "it87" "k10temp" ];
  boot.kernel.sysctl = { "kernel.sysrq" = 1; };

  # Enable ZFS support
  boot.supportedFilesystems = [ "zfs" ];
  # Scrub to find errors
  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
    pools = [ "DATA" ];
  };

  networking = {
    hostName = "arael";
    hostId = "43bd2a4e";
    interfaces.eth0.useDHCP = true;
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Frankfurt";

  # Determines the NixOS release with which your system is to be compatible
  # You should change this only after NixOS release notes say you should.
  system.stateVersion = "19.09";
}
