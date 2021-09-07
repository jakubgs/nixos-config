{ modulesPath, pkgs, ... }:

# This image can be built using nixos-generate.
# https://github.com/nix-community/nixos-generators
{
  imports = [
    (modulesPath + "/virtualisation/digital-ocean-config.nix")
    ../../roles/base.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/netdata.nix
    ../../roles/zerotier.nix
    ../../roles/landing.nix
    ../../roles/nimbus-eth2.nix
  ];

  # SWAP due to low memory
  swapDevices = [
    { device = "/swapfile"; size = 2048; }
  ];

  # Upgrade kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Reboot after 5 seconds on kernel panic
  boot.kernel.sysctl = { "kernel.panic" = 5; };

  networking = {
    hostName = "zeruel";
    hostId = "b9a1a20b";
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
