{ pkgs, lib, ... }:

# This file includes setup for things required for work

let
  # For details see: https://nixos.wiki/wiki/Python
  myPythonPkgs = _: with (pkgs.python310Packages); [
    ipython pip
    # Development
    setuptools retry yapf mohawk grip pyyaml jinja2
    # Devops
    boto3 wakeonlan PyGithub python-hosts cloudflare
    (pkgs.callPackage ../pkgs/consul2.nix {})
    # Security
    pyopenssl cryptography passlib
    # Databases
    elasticsearch psycopg2
    # Statistics
    matplotlib pandas seaborn
    # Misc
    sh backoff
  ];
  myPython = pkgs.python310.withPackages myPythonPkgs;
in {
  # Packages required for work
  users.users.jakubgs.packages = with pkgs; [
    # DevOps
    ansible_2_14
    # Security
    bitwarden unstable.bitwarden-cli sops oathToolkit yubikey-manager
    # Databases
    robo3t
    # Network
    netcat websocat insomnia ngrok tcpdump whois
    # Remote
    remmina
    # Cloud
    awscli s3cmd unstable.doctl google-cloud-sdk
    scaleway-cli aliyun-cli hcloud
    # General dev
    github-cli pkg-config shellcheck
    # Infra dev
    pkgs.unstable.terraform_1
    # NodeJS dev
    nodejs-18_x (yarn.override { nodejs = nodejs-18_x; })
    # GoLang dev
    pkgs.unstable.go_1_19 gocode gopls go-protobuf protobuf3_20
    # Python dev
    myPython
    # Mobile dev
    fastlane apktool jdk8 scrcpy
    # Utils
    jsonnet appimage-run unixtools.xxd bvi binutils-unwrapped
    # Video Recording
    obs-studio
    # Docs
    mdbook hugo
    # Communication
    weechat
  ];

  # Android development Tool
  programs.adb.enable = true;
  users.users.jakubgs.extraGroups = [ "adbusers" ];

  # For emergency use during DNS issues
  #networking.extraHosts = lib.readFile /home/jakubgs/statusim_hosts;

  # Disable Garbage Collection
  nix.gc.automatic = lib.mkForce false;
}
