{ pkgs, ... }:

# This file includes setup for things required for work

{
  # Packages required for work
  users.users.sochan.packages = with pkgs; [
    # Meetings
    zoom-us
    # Infra dev
    terraform ansible
    # Cloud
    doctl
    # GoLang dev
    go
    # Python dev
    python38 python38Packages.ipython python38Packages.pip
    # NodeJS dev
    nodejs-12_x yarn
    # Mobile dev
    fastlane
  ];

  # Android development Tool
  programs.adb.enable = true;
  users.users.sochan.extraGroups = [ "adbusers" ];

  # Simplify accessing Status hosts
  networking.search = [ "statusim.net" ];
}
