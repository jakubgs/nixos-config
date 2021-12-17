# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "rpool/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "rpool/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "rpool/home";
      fsType = "zfs";
    };

  fileSystems."/boot2" =
    { device = "/dev/disk/by-uuid/42277106-1671-4f63-a4d6-67564224ed92";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/e3617ef9-e4c3-4b74-9046-2dfdddeb6988";
      fsType = "ext4";
    };

  fileSystems."/mnt/data" =
    { device = "rpool/secret/data";
      fsType = "zfs";
      options = [ "noauto" "nofail" ];
    };

  fileSystems."/mnt/git" =
    { device = "rpool/secret/git";
      fsType = "zfs";
      options = [ "noauto" "nofail" ];
    };

  fileSystems."/mnt/mobile" =
    { device = "rpool/secret/mobile";
      fsType = "zfs";
      options = [ "noauto" "nofail" ];
    };

  fileSystems."/mnt/music" =
    { device = "rpool/secret/music";
      fsType = "zfs";
      options = [ "noauto" "nofail" ];
    };

  fileSystems."/mnt/photos" =
    { device = "rpool/secret/photos";
      fsType = "zfs";
      options = [ "noauto" "nofail" ];
    };

  fileSystems."/git" =
    { device = "/mnt/git";
      fsType = "none";
      options = [ "noauto" "nofail" "bind" ];
    };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
