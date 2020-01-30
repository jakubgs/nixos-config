# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/security.nix
    ../../roles/base.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/autofs.nix
    ../../roles/desktop.nix
    ../../roles/docker.nix
    ../../roles/zerotier.nix
    ../../roles/yubikey.nix
    ../../roles/work.nix
    ../../roles/landing.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
  };
  boot.loader.efi = {
    #efiSysMountPoint = "/boot/efi";
    canTouchEfiVariables = false;
  };
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.device = "nodev";
  #boot.loader.grub.devices = [
  #  #"/dev/disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S4XBNE0M728642F"
  #  #"/dev/disk/by-id/ata-SanDisk_Ultra_II_480GB_154915446195"
  #  "/dev/disk/by-id/ata-WDC_WD5003AZEX-00MK2A0_WD-WCC3FLEPNYKK"
  #  "/dev/disk/by-id/ata-WDC_WD5003AZEX-00MK2A0_WD-WCC3FLNKZN87"
  #];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "nct6775" "coretemp" ];
  boot.kernel.sysctl = { "kernel.sysrq" = 1; };

  # Enable ZFS support
  # WARNING: All mountpoints need to be set to 'legacy'
  boot.supportedFilesystems = [ "zfs" ];
  # Scrub to find errors
  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
    pools = [ "rpool" ];
  };
  # Snapshot weekly
  services.zfs.autoSnapshot = {
    enable = true;
    flags = "-k -p --utc";
    monthly = 12;
    weekly = 4;
    daily = 3;
    hourly = 0;
    frequent = 0;
  };

  networking = {
    hostName = "caspair";
    hostId = "9fbd8b5d";
    useDHCP = false;
    interfaces = {
      eno1 = { useDHCP = true; };
    };
  };
  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  console = {
    font = "Lat2-Terminus16";
    keyMap = "pl";
  };
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Determines the NixOS release with which your system is to be compatible
  # You should change this only after NixOS release notes say you should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
