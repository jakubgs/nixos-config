{ pkgs, lib, ... }:

# This file includes setup for things required for work

let
  # For details see: https://nixos.wiki/wiki/Python
  myPythonPkgs = _: with (pkgs.python3Packages); [
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
  myPython = pkgs.python3.withPackages myPythonPkgs;
in {
  # Packages required for work
  users.users.jakubgs.packages = with pkgs; [
    # DevOps
    ansible_2_17 terraform_1 mosh
    # Development
    gnumake gcc autoconf automake patchelf
    # Security
    vault sops pwgen oathToolkit yubikey-manager openssl
    # Databases
    robo3t
    # Network
    mtr netcat websocat insomnia ngrok tcpdump whois inetutils
    # Remote
    remmina
    # Cloud
    awscli s5cmd doctl google-cloud-sdk
    scaleway-cli pkgs.unstable.aliyun-cli hcloud
    # Ethereum
    (pkgs.callPackage ../pkgs/eth-cli.nix {})
    # General dev
    git-filter-repo github-cli pkg-config shellcheck dos2unix
    # NodeJS dev
    nodejs_22 (yarn.override { nodejs = nodejs_22; })
    # GoLang dev
    go_1_23 gopls
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

  # Add Status cache to configured ones.
  nix.settings = {
    trusted-substituters = [ "https://nix-cache.status.im/" ];
    trusted-public-keys = [ "nix-cache.status.im-1:x/93lOfLU+duPplwMSBR+OlY4+mo+dCN7n0mr4oPwgY=" ];
  };
}
