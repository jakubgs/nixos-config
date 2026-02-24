{ lib, ... }:

{
  # Disable all suspend methods.
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Disable networking
  networking.useDHCP = lib.mkForce false;
  networking.interfaces = {};
}
