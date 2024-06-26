# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" ];
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

  fileSystems."/mnt/photos" =
    { device = "rpool/secret/photos";
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

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
