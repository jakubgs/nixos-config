{ pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/hardened.nix")
    (modulesPath + "/profiles/headless.nix")
    ./hardware-configuration.nix
    ../../roles/base
    ../../roles/mosh.nix
    ../../roles/syncthing.nix
    ../../roles/metrics/prometheus.nix
    ../../roles/alertmanager.nix
    ../../roles/grafana.nix
    ../../roles/gitweb.nix
    ../../roles/nfs.nix
    ../../roles/gossa.nix
    ../../roles/karakeep.nix
    ../../roles/builder.nix
    ../../roles/cache.nix
    ../../roles/invidious.nix
    ../../roles/qemu.nix
  ];

  # Fix for GLIBC errors due to 'scudo' from hardened profile.
  # https://github.com/NixOS/nix/issues/6563
  environment.memoryAllocator.provider = "libc";

  # Hetzner KVMs are limited, better to always force.
  boot.zfs.requestEncryptionCredentials = false;

  # Use the GRUB 2 boot loader.
  boot.loader.grub = {
    enable = true;
    configurationLimit = 10;
    copyKernels = true;
    mirroredBoots = [
      {
        devices = ["/dev/disk/by-id/ata-TOSHIBA_MG04ACA400EY_586IK061F7GB"];
        path = "/boot1";
      }
      {
        devices = ["/dev/disk/by-id/ata-TOSHIBA_MG04ACA400EY_586IK063F7GB"];
        path = "/boot2";
      }
    ];
  };

  # Specify kernel version.
  boot.kernelPackages = pkgs.linuxPackages_6_17;

  # Disabled by hardened profile, big performance hit.
  security.allowSimultaneousMultithreading = true;

  networking = {
    hostId = "4b16a017";
    interfaces.eth0.useDHCP = true;
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Set your time zone.
  time.timeZone = "Europe/Frankfurt";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "21.11";
}
