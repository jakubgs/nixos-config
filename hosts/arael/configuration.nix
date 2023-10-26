{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/base.nix
    ../../roles/zfs.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/zerotier.nix
    ../../roles/landing.nix
    ../../roles/mikrotik.nix
    ../../roles/iperf.nix
    ../../roles/nfs.nix
    ../../roles/gossa.nix
    ../../roles/samba.nix
    ../../roles/syncthing.nix
    ../../roles/torrent.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    timeout = 5;
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

  # Get new drivers.
  boot.kernelPackages = pkgs.callPackage ./kernel.nix { };

  boot.zfs = {
    enableUnstable = true;
    # Serial console or keyboard is not easily accessible.
    requestEncryptionCredentials = false;
  };

  # Fix missing modules
  # https://github.com/NixOS/nixpkgs/issues/154163
  nixpkgs.overlays = [
    (final: super: {
      makeModulesClosure = x:
        super.makeModulesClosure (x // { allowMissing = true; });
    })
  ];

  networking = {
    hostName = "arael";
    hostId = "892cff1c";
    useDHCP = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "pl";
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11"; # Did you read the comment?
}
