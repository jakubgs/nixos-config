# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
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
    { device = "rpool/secret/home";
      fsType = "zfs";
    };

  fileSystems."/mnt/data" =
    { device = "rpool/secret/data";
      fsType = "zfs";
    };

  fileSystems."/mnt/git" =
    { device = "rpool/secret/git";
      fsType = "zfs";
    };

  fileSystems."/mnt/mobile" =
    { device = "rpool/mobile";
      fsType = "zfs";
    };

  fileSystems."/mnt/music" =
    { device = "rpool/music";
      fsType = "zfs";
    };

  fileSystems."/var/lib/docker" =
    { device = "rpool/docker";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/0BE7-9164";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/37f94f00-5def-4dfe-b055-7452b120c9b1"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  # high-resolution display
  hardware.video.hidpi.enable = lib.mkDefault true;
}
