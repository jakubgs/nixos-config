{ config, pkgs, lib, ... }:

let
  # Noevim 0.5.0 is not releaed yet and not merged into nixpkgs.
  # https://github.com/NixOS/nixpkgs/pull/110837
  neovimNixpkgs = import (pkgs.fetchzip {
    url = "https://github.com/rvolosatovs/nixpkgs/archive/517f1b4a6127226d11a6be06246fc2af1ab88ff4.zip";
    sha256 = "05cxcaj3vgk81brx7w6bndxgc502rmmcmnrqgllbc57dyfq4fm4i";
  }) {};
in {
  imports = [
    ./nix.nix
  ];

  # Packages
  environment.systemPackages = with pkgs; [
    # utilities
    file zsh bash wget curl manpages sudo pass bc rename sqlite
    # building
    gnumake gcc autoconf automake patchelfUnstable
    unrar unzip zip envsubst entr
    # processes
    dtach reptyr pstree killall
    # monitoring
    htop iotop iftop multitail
    # dev tools
    neovimNixpkgs.neovim jq tmux fzf silver-searcher
    git qrencode
    # hardware tools
    pciutils lm_sensors acpi pmutils usbutils dmidecode
    # networking
    nmap nettools traceroute dnsutils wol iperf
    # filesystems
    zfs zfstools inotify-tools ncdu lsof parted ntfs3g gptfdisk
    # network filesystems
    nfs-utils
    # hard drive management
    lsscsi hddtemp hdparm perf-tools
    # security
    openssl
  ];

  # Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Editor
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # SysRQ is useful when things hang
  boot.kernel.sysctl = { "kernel.sysrq" = 1; };

  # nobody cares about ipv6
  boot.kernelParams = [ "ipv6.disable=1" ];
  networking.enableIPv6 = false;

  # domain use for my own infra
  networking.search = [ "magi.blue" ];

  # NTP Server
  services.chrony.enable = true;
}
