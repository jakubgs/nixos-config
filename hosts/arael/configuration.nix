{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/base.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/zerotier.nix
  ];

  # Upgrade kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # Modules for sensors
  boot.kernelModules = [ "it87" "k10temp" ];
  boot.kernelParams = [ "ipv6.disable=1" ];
  boot.kernel.sysctl = { "kernel.sysrq" = 1; };

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.device = "/dev/disk/by-label/nixos";
  # To avoid some boot errors
  boot.loader.grub.copyKernels = true;

  networking = {
    hostName = "arael";
    hostId = "43bd2a4e";
    domain = "magi";
    search = [ "magi.blue" ];
    enableIPv6 = false;
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
