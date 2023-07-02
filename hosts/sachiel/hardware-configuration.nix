# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "uas" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
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

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/4adaf361-6b1e-47d1-95e3-c24d53f3937c";
      fsType = "ext4";
    };

  fileSystems."/git" =
    { device = "/mnt/git";
      fsType = "none";
      options = [ "noauto" "nofail" "bind" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/3b90983f-f3a4-4526-b90b-194e2445216b"; }
    ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
