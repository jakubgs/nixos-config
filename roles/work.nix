{ pkgs, lib, ... }:

# This file includes setup for things required for work

let
  # For details see: https://nixos.wiki/wiki/Python
  myPythonPkgs = python-packages: with (pkgs.python38Packages); [
    ipython pip yapf ansible
    setuptools boto3 retry
    pyopenssl cryptography
    elasticsearch wakeonlan
    # Statistics
    matplotlib pandas seaborn
  ];
  myPython = pkgs.python38.withPackages myPythonPkgs;
in {
  # Packages required for work
  users.users.sochan.packages = with pkgs; [
    # Network
    netcat insomnia ngrok tcpdump
    # Remote
    remmina
    # Infra dev
    terraform
    # AWS
    awscli
    # DigitalOcean
    doctl
    # Google Cloud
    google-cloud-sdk
    # Scaleway
    scaleway-cli
    # General dev
    pkg-config
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

  # Disable Garbage Collection
  nix.gc.automatic = lib.mkForce false;
}
