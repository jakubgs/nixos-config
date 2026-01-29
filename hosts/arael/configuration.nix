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
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Serial console or keyboard is not easily accessible.
  boot.zfs.requestEncryptionCredentials = false;

  # Avoid memory-starving processes via ZFS pool scan bug.
  # https://github.com/openzfs/zfs/pull/17542
  boot.kernelParams = [
    "cma=128M"                        # Contiguous Memory Allocator
    "zfs.zfs_prefetch_disable=1"      # Disable loading extra data into ARC
    "zfs.zfs_dedup_prefetch=0"        # Disable memory hungry deduplication
    "zfs.zfs_arc_min=0"               # Make shrinking easier
    "zfs.zfs_arc_max=1073741824"      # 1 GiB hard limit
    "zfs.zfs_arc_sys_free=1073741824" # 1 GiB kept for system
    "zfs.zfs_scan_strict_mem_lim=1"   # Enforce tight memory limits
    "zfs.zfs_scrub_min_time_ms=500"   # Reduce time between TXG flushes.
  ];
  boot.kernel.sysctl = {
    "vm.swappiness" = lib.mkForce 60;  # Prefer shrinking ARC over swapping.
    "vm.min_free_kbytes" = 65536;      # 64 MiB
    "vm.watermark_scale_factor" = 150;
    "vm.vfs_cache_pressure" = 1000;    # reclaim dentries/inodes faster
  };

  # Limit memory usage of individual services.
  systemd.services.transmission.serviceConfig.MemoryMax = "300M";
  systemd.services.invidious.serviceConfig.MemoryMax = "400M";
  systemd.services.syncthing.serviceConfig.MemoryMax = "500M";
  systemd.services.netdata.serviceConfig.MemoryMax = "150M";

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
