{ pkgs, ... }:

# This file includes setup for things required for work

{
  # Packages required for work
  users.users.sochan.packages = with pkgs; [
    # Meetings
    zoom-us
    # Infra dev
    terraform ansible
    # GoLang dev
    go
    # NodeJS dev
    nodejs-12_x yarn
    # Mobile dev
    fastlane
  ];

  # Simplify accessing Status hosts
  networking.search = [ "statusim.net" ];
}
