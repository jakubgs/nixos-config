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

  # Avoid memory-starving processes via ZFS pool scan bug.
  # TODO: Remove once upgraded to ZFS 2.4.0 which includes:
  # https://github.com/openzfs/zfs/pull/17542
  boot.kernelParams = [
    "cma=128M"                          # Contiguous Memory Allocator
    "zfs.zfs_arc_min=0"                 # Make shrinking easier
    "zfs.zfs_arc_max=1073741824"        # 1 GiB hard limit
    "zfs.zfs_scan_mem_lim_fact=200"     # 1/200th of RAM hard limit
    "zfs.zfs_scan_mem_lim_soft_fact=20" # 1/20th of hard limit
    "zfs.zfs_scan_strict_mem_lim=1"     # Enforce tight memory limits
    "zfs.zfs_scan_vdev_limit=4194304"   # 4 MiB for scrub per leaf device
    "zfs.zfs_vdev_scrub_max_active=1"   # Max active I/Os per vdev
    "zfs.zfs_scrub_min_time_ms=500"     # Reduce time between TXG flushes.
  ];
  boot.kernel.sysctl = {
    "vm.min_free_kbytes" = 524288; # 512 MiB
    "vm.watermark_scale_factor" = 300;
  };

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
