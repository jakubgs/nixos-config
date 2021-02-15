{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./rockchip-kernel-config.nix
    ../../roles/security.nix
    ../../roles/base.nix
    ../../roles/zfs.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/netdata.nix
    ../../roles/wireless.nix
    ../../roles/zerotier.nix
    ../../roles/landing.nix
    ../../roles/distbuild.nix
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
  powerManagement.cpuFreqGovernor = "ondemand";

  # Networking
  networking = {
    hostName = "sachiel";
    hostId = "3cd72605";
    useDHCP = true;
  };

  # Miscellaneous
  time.timeZone = "Europe/Warsaw";

  # High-DPI console
  console.font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  # Enable sound.
  sound.enable = true;

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "20.09";
}
