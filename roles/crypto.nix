{ pkgs, ... }:

{
  # Packages required for work
  users.users.sochan.packages = with pkgs; [
    ledger-live-desktop
  ];

  # Enable udev rules for Ledger
  hardware.ledger.enable = true;
}
