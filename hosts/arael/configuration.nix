{ modulesPath, pkgs, ... }:

# This image can be built using nixos-generate.
# https://github.com/nix-community/nixos-generators
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    (modulesPath + "/profiles/hardened.nix")
    (modulesPath + "/profiles/headless.nix")
    ./hardware-configuration.nix
    ../../roles/base.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/netdata.nix
    ../../roles/zerotier.nix
    ../../roles/landing.nix
    ../../roles/nimbus-eth2.nix
  ];

  # Decrypt after boot
  boot.zfs.forceImportRoot = true;
  boot.zfs.requestEncryptionCredentials = false;

  # Bootloader
  boot.loader.grub = {
    enable = true;
    version = 2;
    configurationLimit = 10;
    copyKernels = true;
    devices = ["/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0-0-0-0"];
  };

  # Reboot after 5 seconds on kernel panic
  boot.kernel.sysctl = { "kernel.panic" = 5; };

  networking = {
    hostName = "arael";
    hostId = "fced3cc3";
    interfaces.enp1s0.useDHCP = true;
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
  };
  console = {
    font = "Lat2-Terminus16";
    keyMap = "pl";
  };

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "21.11";
}
