{ pkgs, ... }:

{
  # Packages required for work
  users.users.sochan.packages = with pkgs; [
    ledger-live-desktop
  ];
}
