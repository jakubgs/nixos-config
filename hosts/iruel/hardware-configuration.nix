# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/mnt/data" =
    { device = "USB-DATA/data";
      fsType = "zfs";
      options = [ "noauto" "nofail" ];
    };

  fileSystems."/mnt/git" =
    { device = "USB-DATA/git";
      fsType = "zfs";
      options = [ "noauto" "nofail" ];
    };

  fileSystems."/mnt/mobile" =
    { device = "USB-DATA/mobile";
      fsType = "zfs";
      options = [ "noauto" "nofail" ];
    };

  fileSystems."/mnt/music" =
    { device = "USB-DATA/music";
      fsType = "zfs";
      options = [ "noauto" "nofail" ];
    };

  fileSystems."/mnt/photos" =
    { device = "USB-DATA/photos";
      fsType = "zfs";
      options = [ "noauto" "nofail" ];
    };

  fileSystems."/mnt/grzegorz" =
    { device = "USB-DATA/grzegorz";
      fsType = "zfs";
      options = [ "noauto" "nofail" ];
    };


  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enP4p1s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.ztbto5ttab.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
