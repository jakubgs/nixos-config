{ pkgs, ... }:

{
  # Packages required for work
  users.users.jakubgs.packages = with pkgs; [
    ledger-live-desktop
  ];

  # https://github.com/LedgerHQ/udev-rules
  # Enable udev rules for Ledger
  hardware.ledger.enable = true;
}
