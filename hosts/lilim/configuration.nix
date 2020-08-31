{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # See: https://github.com/NixOS/nixos-hardware
    <nixos-hardware/lenovo/thinkpad/t480s>
    ../../roles/security.nix
    ../../roles/base.nix
    ../../roles/zfs.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/autofs.nix
    ../../roles/desktop.nix
    ../../roles/physlock.nix
    ../../roles/docker.nix
    ../../roles/zerotier.nix
    ../../roles/yubikey.nix
    ../../roles/work.nix
    ../../roles/docs.nix
    ../../roles/qemu.nix
    ../../roles/syncthing.nix
    ../../roles/netdata.nix
    ../../roles/landing.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;

  # Upgrade kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Scrub to find errors
  services.zfs.autoScrub = {
    enable = true;
    interval = "weekly";
    pools = [ "rpool" ];
  };

  networking = {
    hostName = "lilim";
    hostId = "e87975cc";
    useDHCP = false;
    interfaces = {
      enp0s31f6 = { useDHCP = true; };
    };
  };
  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "pl";

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Power auto tuning on startup
  powerManagement.powertop.enable = true;

  # Determines the NixOS release with which your system is to be compatible
  # You should change this only after NixOS release notes say you should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
