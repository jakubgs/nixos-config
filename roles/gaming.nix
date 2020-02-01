{ pkgs, ... }:

{
  # Packages required for work
  users.users.sochan.packages = with pkgs; [
    steam lutris
  ];
}
