{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../roles/security.nix
    ../../roles/base.nix
    ../../roles/zfs.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/netdata.nix
    ../../roles/wireless.nix
    ../../roles/zerotier.nix
    ../../roles/landing.nix
  ];

  # Boot
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible = {
    enable = true;
    configurationLimit = 10;
  };
  # Latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "ehci_pci" "nvme" ];
  boot.initrd.availableKernelModules = [ "ehci_pci" "nvme" ];

  # PCI: rockchip: Workaround bus scan crashes with some PCIe devices 
  boot.kernelParams = [ "pcie_rk_bus_scan_delay=500" ];
  boot.kernelPatches = [{
    name = "rockpro64-pcie-scan-sleep.patch";
    patch = ../../files/patches/rockpro64-pcie-scan-sleep.patch;
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
