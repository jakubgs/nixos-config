{ pkgs, lib, ... }:

# This file includes setup for things required for work

let
  # For details see: https://nixos.wiki/wiki/Python
  myPythonPkgs = _: with (pkgs.python310Packages); [
    ipython pip
    # Development
    setuptools retry yapf mohawk grip pyyaml jinja2
    # Devops
    boto3 wakeonlan gitpython PyGithub python-hosts cloudflare
    (pkgs.callPackage ../pkgs/consul2.nix {})
    # Ethereum
    (pkgs.callPackage ../pkgs/staking-deposit-cli.nix {})
    # Security
    pyopenssl cryptography passlib hvac
    # Databases
    elasticsearch elastic-transport psycopg2
    # Statistics
    matplotlib pandas seaborn
    # Misc
    sh backoff psutil
  ];
  myPython = pkgs.python310.withPackages myPythonPkgs;
in {
  # Packages required for work
  users.users.jakubgs.packages = with pkgs; [
    # DevOps
    mosh unstable.ansible_2_16
    # Security
    vault bitwarden unstable.bitwarden-cli
    sops pwgen oathToolkit yubikey-manager
    # Databases
    robo3t
    # Network
    mtr netcat websocat insomnia ngrok tcpdump whois inetutils
    # Remote
    remmina
    # Cloud
    awscli s3cmd unstable.doctl google-cloud-sdk
    scaleway-cli aliyun-cli hcloud
    # General dev
    git-filter-repo github-cli pkg-config shellcheck dos2unix
    # Infra dev
    pkgs.unstable.terraform_1
    # NodeJS dev
    nodejs-18_x (yarn.override { nodejs = nodejs-18_x; })
    # GoLang dev
    pkgs.go_1_21 gopls go-protobuf protobuf3_20
    # Python dev
    myPython
    # Mobile dev
    fastlane apktool jdk8 scrcpy
    # Utils
    jsonnet appimage-run unixtools.xxd bvi binutils-unwrapped direnv
    # Video Recording
    obs-studio
    # Docs
    mdbook hugo
    # Communication
    weechat asciinema element-desktop telegram-desktop
  ];

  # Android development Tool
  programs.adb.enable = true;
  users.users.jakubgs.extraGroups = [ "adbusers" ];

  # For emergency use during DNS issues
  #networking.extraHosts = lib.readFile /home/jakubgs/statusim_hosts;

  # Disable Garbage Collection
  nix.gc.automatic = lib.mkForce false;
}
