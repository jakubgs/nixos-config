{ pkgs, lib, ... }:

# This file includes setup for things required for work

let
  unstablePkgs = import <nixos-unstable> { };
  aliyun-cli = pkgs.callPackage ../pkgs/aliyun-cli.nix { };

  # For details see: https://nixos.wiki/wiki/Python
  myPythonPkgs = python-packages: with (pkgs.python38Packages); [
    ipython pip
    # Development
    setuptools retry yapf mohawk grip pyyaml jinja2
    # Devops
    boto3 wakeonlan PyGithub consul python-hosts
    # Security
    pyopenssl cryptography passlib
    # Databases
    elasticsearch psycopg2
    # Statistics
    matplotlib pandas seaborn
  ];
  myPython = pkgs.python38.withPackages myPythonPkgs;
in {
  # Packages required for work
  users.users.jakubgs.packages = with pkgs; [
    # DevOps
    nixopsUnstable unstablePkgs.ansible_2_11
    # Security
    unstablePkgs.bitwarden-cli
    # Databases
    robomongo
    # Network
    netcat insomnia ngrok tcpdump
    # Remote
    remmina
    # Cloud
    awscli s3cmd doctl google-cloud-sdk
    scaleway-cli aliyun-cli hcloud
    # General dev
    github-cli pkg-config shellcheck
    # Infra dev
    unstablePkgs.terraform_1_0
    # NodeJS dev
    unstablePkgs.nodejs-14_x yarn
    # GoLang dev
    go_1_16 gocode gopls go-protobuf
    # Python dev
    myPython
    # Ruby dev
    ruby_2_7
    # Mobile dev
    fastlane apktool jdk8
    # Utils
    jsonnet appimage-run unixtools.xxd bvi
    # Docs
    #libreoffice
  ];

  # Android development Tool
  programs.adb.enable = true;
  users.users.jakubgs.extraGroups = [ "adbusers" ];

  # Simplify accessing Status hosts
  networking.search = [ "statusim.net" "hosts.dap.ps" ];

  # Disable Garbage Collection
  nix.gc.automatic = lib.mkForce false;
}
