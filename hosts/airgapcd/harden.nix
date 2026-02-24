{ lib, ... }:

{
  # Run entirely from RAM, quieter logs.
  boot.kernelParams = [
    "copytoram"
    "quiet"
    "loglevel=3"
    "init_on_alloc=1"
    "init_on_free=1"
    "vsyscall=none"
  ];

  # Use improved randomness generator.
  services.jitterentropy-rngd.enable = true;

  # Disable all suspend methods.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Disable networking
  networking.useDHCP = lib.mkForce false;
  networking.interfaces = {};
}
