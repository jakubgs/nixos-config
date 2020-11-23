{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/security.nix
    ../../roles/base.nix
    ../../roles/zfs.nix
    ../../roles/users.nix
    ../../roles/network.nix
    ../../roles/locate.nix
    ../../roles/autofs.nix
    ../../roles/desktop.nix
    ../../roles/physlock.nix
    ../../roles/printer.nix
    ../../roles/gaming.nix
    ../../roles/docker.nix
    ../../roles/zerotier.nix
    ../../roles/yubikey.nix
    ../../roles/syncthing.nix
    ../../roles/work.nix
    ../../roles/docs.nix
    ../../roles/qemu.nix
    ../../roles/netdata.nix
    ../../roles/landing.nix
    ../../roles/crypto.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.grub.enable = false;
  boot.loader.efi = {
    efiSysMountPoint = "/efi";
    canTouchEfiVariables = true;
  };
  # Upgrade kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "nct6775" "coretemp" "i2c-1" ];

  # Scrub to find errors
  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
    pools = [ "rpool" "DATA" ];
  };

  networking = {
    hostName = "caspair";
    hostId = "9fbd8b5d";
    useDHCP = false;
    interfaces = {
      eno1 = { useDHCP = true; };
    };
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "pl";
  };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Power Managemtn
  powerManagement.cpuFreqGovernor = "performance";

  # Determines the NixOS release with which your system is to be compatible
  # You should change this only after NixOS release notes say you should.
  system.stateVersion = "20.09"; # Did you read the comment?
}
