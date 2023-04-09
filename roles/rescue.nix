{ pkgs, config, lib, ... }:

let
  netboot = import (pkgs.path + "/nixos/lib/eval-config.nix") {
    system = config.nixpkgs.hostPlatform.system;
    modules = [
      (pkgs.path + "/nixos/modules/installer/netboot/netboot-minimal.nix")
      { boot.supportedFilesystems = [ "zfs" ]; }
    ];
  };
in {
  boot.loader.systemd-boot.extraEntries = {
    "rescue.conf" = ''
      title "Nixos Rescue"
      linux /efi/Linux/rescue-kernel init=${netboot.config.system.build.toplevel}/init ${toString netboot.config.boot.kernelParams}
      initrd /efi/Linux/rescue-initrd
    '';
  };
  boot.loader.systemd-boot.extraFiles = {
    "efi/Linux/rescue-kernel" = "${netboot.config.system.build.kernel}/bzImage";
    "efi/Linux/rescue-initrd" = "${netboot.config.system.build.netbootRamdisk}/initrd";
  };
}
