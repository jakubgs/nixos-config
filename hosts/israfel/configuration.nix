{ modulesPath, pkgs, ... }:

{
  imports = [
    (modulesPath + "/profiles/hardened.nix")
    ./hardware-configuration.nix
    ../../roles/base
    ../../roles/ethereum/nimbus-el.nix
    ../../roles/ethereum/nimbus-bn.nix
    ../../roles/ethereum/nimbus-vc.nix
    ../../roles/ethereum/mev-boost.nix
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

  # Let EDK2 provide DTB and do not force NixOS DTB.
  boot.loader.systemd-boot.installDeviceTree = false;
  hardware.deviceTree.enable = false;

  # Load thermal sensor module.
  boot.kernelModules = [ "rockchip-thermal" ];
  # Lock kernel version.
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Serial console or keyboard is not easily accessible.
  boot.zfs.requestEncryptionCredentials = false;

  networking = {
    hostId = "d22a9a6c";
    useDHCP = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11"; # Did you read the comment?
}
