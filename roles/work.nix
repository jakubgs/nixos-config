{ pkgs, lib, ... }:

# This file includes setup for things required for work

let
  # For details see: https://nixos.wiki/wiki/Python
  myPythonPkgs = _: with (pkgs.python38Packages); [
    ipython pip
    # Development
    setuptools retry yapf mohawk grip pyyaml jinja2
    # Devops
    boto3 wakeonlan PyGithub consul python-hosts cloudflare
    # Security
    pyopenssl cryptography passlib
    # Databases
    elasticsearch psycopg2
    # Statistics
    matplotlib pandas seaborn
    # Misc
    backoff
  ];
  myPython = pkgs.python38.withPackages myPythonPkgs;
in {
  # Packages required for work
  users.users.jakubgs.packages = with pkgs; [
    # DevOps
    ansible_2_11
    # Security
    pkgs.unstable.bitwarden-cli oathToolkit
    # Databases
    robomongo
    # Network
    netcat insomnia ngrok tcpdump whois
    # Remote
    remmina
    # Cloud
    awscli s3cmd doctl google-cloud-sdk
    scaleway-cli aliyun-cli hcloud
    # General dev
    github-cli pkg-config shellcheck
    # Infra dev
    pkgs.unstable.terraform_1
    # NodeJS dev
    nodejs-16_x (yarn.override { nodejs = nodejs-16_x; })
    # GoLang dev
    pkgs.unstable.go_1_18 gocode gopls go-protobuf
    # Python dev
    myPython
    # Ruby dev
    ruby_2_7
    # Mobile dev
    fastlane apktool jdk8
    # Utils
    jsonnet appimage-run unixtools.xxd bvi binutils-unwrapped
    # Video Recording
    obs-studio
    # Docs
    mdbook hugo
  ];

  # Android development Tool
  programs.adb.enable = true;
  users.users.jakubgs.extraGroups = [ "adbusers" ];

  # Simplify accessing Status hosts
  networking.search = [ "statusim.net" "hosts.dap.ps" ];

  # For emergency use during DNS issues
  #networking.extraHosts = lib.readFile /home/jakubgs/statusim_hosts;

  # Disable Garbage Collection
  nix.gc.automatic = lib.mkForce false;
}
