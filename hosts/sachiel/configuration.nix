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
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_4_4.override {
    argsOverride = rec {
      src = pkgs.fetchzip {
        url = "https://github.com/friendlyarm/kernel-rockchip/archive/3dd9af3221d2a4ea4caf2865bac5fe9aaf2e2643.zip";
        sha256 = "0x4bfw90bc3diz8763frjscs5sq7lmc4ij03c0vgxr6ahr9axm5c";
      };
      version = "4.4.179";
      modDirVersion = "4.4.179";
    };
  });
  # Fix for Error: selected processor does not support `crc32x w0,w0,x1'
  # See: https://github.com/NixOS/nixpkgs/issues/64916
  boot.kernelPatches = [{
    name = "aarch64-march-fix.patch";
    patch = ./aarch64-march-fix.patch;
  }];
  boot.kernelModules = [ "ehci_pci" "nvme" ];
  boot.initrd.availableKernelModules = [ "ehci_pci" "nvme" ];

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
