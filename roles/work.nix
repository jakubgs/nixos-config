{ pkgs, lib, ... }:

# This file includes setup for things required for work

let
  # For details see: https://nixos.wiki/wiki/Python
  myPythonPkgs = _: with (pkgs.python3Packages); [
    ipython pip
    # Development
    setuptools retry yapf mohawk grip pyyaml jinja2
    # Devops
    boto3 wakeonlan gitpython pygithub python-hosts cloudflare
    (pkgs.callPackage ../pkgs/consul2.nix {})
    # Ethereum
    (pkgs.callPackage ../pkgs/ethstaker-deposit-cli.nix {})
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
    mosh remmina
    # Development
    gnumake gcc autoconf automake patchelf opencode
    # Security
    vault sops pwgen yubikey-manager openssl
    # Network
    mtr netcat websocat ngrok tcpdump whois inetutils
    # Cloud
    awscli s5cmd doctl google-cloud-sdk
    scaleway-cli aliyun-cli hcloud
    # Ethereum
    #(pkgs.callPackage ../pkgs/eth-cli.nix {})
    # General dev
    git-filter-repo github-cli pkg-config shellcheck dos2unix
    # NodeJS dev
    nodejs_22 (yarn.override { nodejs = nodejs_22; })
    # Python dev
    myPython
    # Utils
    jsonnet appimage-run unixtools.xxd bvi binutils-unwrapped direnv
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
