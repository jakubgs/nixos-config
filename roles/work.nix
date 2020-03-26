{ pkgs, ... }:

# This file includes setup for things required for work

with pkgs;
let
  # For details see: https://nixos.wiki/wiki/Python
  myPythonPkgs = python-packages: with python38Packages; [
    ipython pip ansible
    setuptools boto3 retry
    pyopenssl cryptography
    elasticsearch wakeonlan
  ];
  myPython = python38.withPackages myPythonPkgs;
in {
  # Packages required for work
  users.users.sochan.packages = with pkgs; [
    # Network
    netcat insomnia ngrok
    # Remote
    remmina
    # Meetings
    zoom-us
    # Infra dev
    terraform
    # AWS
    awscli
    # DigitalOcean
    doctl
    # GoLang dev
    go
    # Python dev
    myPython
    # NodeJS dev
    nodejs-13_x yarn
    # Mobile dev
    fastlane apktool jdk8
  ];

  # Android development Tool
  programs.adb.enable = true;
  users.users.sochan.extraGroups = [ "adbusers" ];

  # Simplify accessing Status hosts
  networking.search = [ "statusim.net" "hosts.dap.ps" ];
}
