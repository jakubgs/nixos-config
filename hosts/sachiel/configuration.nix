{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/security.nix
    ../../roles/base.nix
    ../../roles/zfs.nix
    ../../roles/smart.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/netdata.nix
    ../../roles/wireless.nix
    ../../roles/zerotier.nix
    ../../roles/syncthing.nix
    ../../roles/landing.nix
    ../../roles/nfs.nix
    ../../roles/music.nix
    ../../roles/torrent.nix
  ];

  # Boot
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
  # Fix for not detecting the NVMe SSD
  boot.kernelPackages = pkgs.linuxPackages_5_10;
  boot.kernelPatches = [{
    name = "pcie-rockchip-config.patch";
    patch = null;
    extraConfig = ''
      NVME_CORE y
      BLK_DEV_NVME y
      NVME_MULTIPATH y
      PCIE_ROCKCHIP y
      PCIE_ROCKCHIP_EP y
      PCIE_ROCKCHIP_HOST y
      PHY_ROCKCHIP_DP y
      PHY_ROCKCHIP_PCIE y
      PHY_ROCKCHIP_USB y
    '';
  }];

  # Reboot after 5 seconds on kernel panic
  boot.kernel.sysctl = { "kernel.panic" = 5; };

  # Enable additional firmware (such as Wi-Fi drivers).
  hardware.enableRedistributableFirmware = true;

  # Lower power usage and heat generation
  powerManagement.cpuFreqGovernor = "powersave";
  powerManagement.cpufreq.min = 408000;
  powerManagement.cpufreq.max = 1416000;

  # Networking
  networking = {
    hostName = "sachiel";
    hostId = "3cd72605";
    useDHCP = true;
  };

  # Miscellaneous
  time.timeZone = "Europe/Warsaw";

  # Enable sound.
  sound.enable = true;
  boot = { # fix for USB not being default card
    extraModprobeConfig = "options snd_usb_audio index=0";
    blacklistedKernelModules = [ "snd_hda_intel" ];
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "20.09";
}
