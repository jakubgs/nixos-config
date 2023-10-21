{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    efi = {
      efiSysMountPoint = "/boot";
      canTouchEfiVariables = true;
    };
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    grub.enable = false;
  };

  networking = {
    hostName = "israfel";
    hostId = "d22a9a6c";
    useDHCP = false;
    interfaces = {
      enP4p1s0 = { useDHCP = true; };
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "pl";
  };

  # Copy the NixOS config and symlink at run/current-system/configuration.nix.
  system.copySystemConfiguration = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11"; # Did you read the comment?

}
