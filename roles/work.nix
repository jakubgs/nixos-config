{ pkgs, lib, ... }:

# This file includes setup for things required for work

let
  unstablePkgs = import <nixos-unstable> { };

  # For details see: https://nixos.wiki/wiki/Python
  myPythonPkgs = python-packages: with (pkgs.python38Packages); [
    ipython pip
    # Development
    setuptools retry yapf mohawk
    # Devops
    ansible boto3 wakeonlan PyGithub
    # Security
    pyopenssl cryptography
    # Databases
    elasticsearch psycopg2
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
    # Infra dev
    unstablePkgs.terraform_0_13
    # NodeJS dev
    unstablePkgs.nodejs-14_x yarn
    # GoLang dev
    go
    # Python dev
    myPython
    # Mobile dev
    fastlane apktool jdk8
    # Utils
    jsonnet appimage-run unixtools.xxd bvi
    # Docs
    #libreoffice
  ];

  # Android development Tool
  programs.adb.enable = true;
  users.users.sochan.extraGroups = [ "adbusers" ];

  # Simplify accessing Status hosts
  networking.search = [ "statusim.net" "hosts.dap.ps" ];

  # Disable Garbage Collection
  nix.gc.automatic = lib.mkForce false;
}
