{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/base
    ../../roles/mikrotik.nix
    ../../roles/iperf.nix
    ../../roles/nfs.nix
    ../../roles/gossa.nix
    ../../roles/samba.nix
    ../../roles/syncthing.nix
    ../../roles/torrent.nix
    ../../roles/invidious.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    timeout = 5;
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    grub.enable = false;
  };

  # Lock kernel version.
  boot.kernelPackages = pkgs.linuxPackages_6_17;

  # Serial console or keyboard is not easily accessible.
  boot.zfs.requestEncryptionCredentials = false;

  # Avoid memory-starving processes
  boot.kernelParams = [
    "zfs.zfs_arc_min=0"            # Make shrinking easier
    "zfs.zfs_arc_max=1073741824"   # 1 GiB
    "zfs.zfs_arc_meta_balance=100" # Reduce metadata caching
  ];

  # Limit memory usage of individual services.
  systemd.services.transmission.serviceConfig.MemoryMax = "400M";
  systemd.services.invidious.serviceConfig.MemoryMax = "400M";
  systemd.services.syncthing.serviceConfig.MemoryMax = "500M";

  networking = {
    hostId = "892cff1c";
    useDHCP = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11"; # Did you read the comment?
}
