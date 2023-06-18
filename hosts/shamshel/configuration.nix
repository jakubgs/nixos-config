{ modulesPath, pkgs, ... }:

# This image can be built using nixos-generate.
# https://github.com/nix-community/nixos-generators
{
  imports = [
    (modulesPath + "/profiles/hardened.nix")
    (modulesPath + "/profiles/headless.nix")
    ./hardware-configuration.nix
    ../../roles/base.nix
    ../../roles/users.nix
    ../../roles/locate.nix
    ../../roles/zerotier.nix
    ../../roles/landing.nix
    ../../roles/builder.nix
  ];

  # Fix for GLIBC errors due to 'scudo' from hardened profile.
  # https://github.com/NixOS/nix/issues/6563
  environment.memoryAllocator.provider = "libc";

  # Disabled by hardened profile, big performance hit.
  security.allowSimultaneousMultithreading = true;

  # Reboot after 5 seconds on kernel panic
  boot.kernel.sysctl = { "kernel.panic" = 5; };

  networking = {
    hostName = "shamshel";
    hostId = "de25ccd4";
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
  time.timeZone = "Europe/Berlin";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
