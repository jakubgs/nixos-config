{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../roles/security.nix
    ../../roles/base.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/autofs.nix
    ../../roles/docker.nix
    ../../roles/wireless.nix
    ../../roles/zerotier.nix
    ../../roles/syncthing.nix
    ../../roles/usb-backup.nix
    ../../services/usb-backup.nix
  ];

  # Boot
  boot.loader.grub.enable = false;
  boot.loader.raspberryPi = {
    enable = true;
    version = 4;
  };

  # Kernel configuration
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.kernelParams = ["cma=64M" "console=tty0"];

  # Enable ZFS support
  boot.supportedFilesystems = [ "zfs" ];
  # Scrub to find errors
  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
    pools = [ "USB-HDD" ];
  };
  # Snapshot daily
  services.zfs.autoSnapshot = {
    enable = true;
    flags = "-k -p --utc";
    monthly = 4;
    weekly = 2;
    daily = 7;
    hourly = 0;
    frequent = 0;
  };

  # Enable additional firmware (such as Wi-Fi drivers).
  hardware.enableRedistributableFirmware = true;

  # Lower power usage and heat generation
  powerManagement.cpuFreqGovernor = "ondemand";

  # Filesystems
  swapDevices = [ { device = "/swapfile"; size = 1024; } ];

  # Networking
  networking = {
    hostName = "leliel";
    hostId = "cf51a179";
    useDHCP = true;
  };

  # Miscellaneous
  time.timeZone = "Europe/Warsaw";

  # High-DPI console
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  # SMART won't work on Raspberry Pi
  services.smartd.enable = lib.mkForce false;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "20.03";
}
