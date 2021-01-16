{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../roles/security.nix
    ../../roles/base.nix
    ../../roles/zfs.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/netdata.nix
    ../../roles/zerotier.nix
    ../../roles/syncthing.nix
    ../../roles/gitweb.nix
    ../../roles/netdata.nix
    ../../roles/gossa.nix
    ../../roles/landing.nix
    ../../roles/prometheus.nix
    ../../roles/alertmanager.nix
    ../../roles/grafana.nix
  ];

  # SWAP due to low memory
  swapDevices = [
    { device = "/swapfile"; size = 4096; }
  ];

  # No need to tinker with AWS bootloader
  boot.loader.grub.device = "nodev";

  # Upgrade kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking = {
    hostName = "arael";
    hostId = "43bd2a4e";
    interfaces.eth0.useDHCP = true;
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
  time.timeZone = "Europe/Frankfurt";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "20.09";
}
