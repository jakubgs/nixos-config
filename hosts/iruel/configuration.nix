{ modulesPath, config, lib, pkgs, ... }:

{
  imports = [
    (modulesPath + "/profiles/hardened.nix")
    ./hardware-configuration.nix
    ./disko-config.nix
    ../../roles/base.nix
    ../../roles/zfs.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/zerotier.nix
    ../../roles/landing.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    efi = {
      efiSysMountPoint = "/boot";
      canTouchEfiVariables = true;
    };
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
    grub.enable = false;
  };

  # Load thermal sensor module.
  boot.kernelModules = [ "rockchip-thermal" ];
  # Lock kernel version.
  boot.kernelPackages = pkgs.linuxPackages_6_6;
  # Fix missing symbols dropped in kernel 6.2.
  boot.zfs.removeLinuxDRM = true;

  # Serial console or keyboard is not easily accessible.
  boot.zfs.requestEncryptionCredentials = false;

  networking = {
    hostId = "b3c24b35";
    useDHCP = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "24.11"; # Did you read the comment?
}
