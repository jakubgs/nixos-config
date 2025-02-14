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
    ../../roles/mev-boost.nix
    ../../roles/go-ethereum.nix
    ../../roles/nimbus-eth2.nix
    ../../roles/mev-boost.nix
  ];

  # Fix for GLIBC errors due to 'scudo' from hardened profile.
  # https://github.com/NixOS/nix/issues/6563
  environment.memoryAllocator.provider = "libc";

  # Disabled by hardened profile, big performance hit.
  security.allowSimultaneousMultithreading = true;

  # Decrypt after boot
  boot.zfs.forceImportRoot = true;
  boot.zfs.requestEncryptionCredentials = false;

  # Bootloader
  boot.loader.grub = {
    enable = true;
    configurationLimit = 10;
    copyKernels = true;
    mirroredBoots = [
      {
        devices = ["/dev/disk/by-id/ata-Micron_1100_MTFDDAK512TBN_172618D7FA26"];
        path = "/boot1";
      }
      {
        devices = ["/dev/disk/by-id/ata-Micron_1100_MTFDDAK512TBN_172618D7FAB2"];
        path = "/boot2";
      }
    ];
  };

  # Reboot after 5 seconds on kernel panic
  boot.kernel.sysctl = { "kernel.panic" = 5; };

  networking.hostId = "e88bc7da";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.05";
}
