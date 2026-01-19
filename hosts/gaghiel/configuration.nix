{ modulesPath, config, lib, pkgs, ... }:

{
  imports = [
    (modulesPath + "/profiles/hardened.nix")
    ./disko-config.nix
    ./usb-storage.nix
    ../../roles/base
    ../../roles/iperf.nix
    ../../roles/nfs.nix
    ../../roles/samba.nix
    ../../roles/syncthing.nix
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
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  networking = {
    hostId = "76fd6dc8";
    useDHCP = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "25.05"; # Did you read the comment?
}
