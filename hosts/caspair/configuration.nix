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
    #../../roles/printer.nix
    ../../roles/gaming.nix
    ../../roles/docker.nix
    ../../roles/zerotier.nix
    ../../roles/yubikey.nix
    ../../roles/syncthing.nix
    ../../roles/work.nix
    ../../roles/qemu.nix
    ../../roles/landing.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.grub.enable = false;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "nct6775" "coretemp" "i2c-1" ];
  boot.kernel.sysctl = { "kernel.sysrq" = 1; };

  # Enable ZFS support
  # WARNING: All mountpoints need to be set to 'legacy'
  boot.supportedFilesystems = [ "zfs" ];
  # Scrub to find errors
  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
    pools = [ "rpool" "DATA" ];
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
