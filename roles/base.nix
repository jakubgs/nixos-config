{ config, pkgs, lib, ... }:

{
  # Packages
  environment.systemPackages = with pkgs; [
    # utilities
    file zsh bash wget curl manpages sudo pass bc rename sqlite
    # building
    gnumake gcc unrar unzip zip envsubst entr patchelfUnstable
    # processes
    dtach reptyr pstree killall
    # monitoring
    htop iotop iftop multitail
    # dev tools
    neovim jq tmux fzf silver-searcher
    git qrencode
    # hardware tools
    pciutils lm_sensors acpi pmutils usbutils dmidecode
    # networking
    nmap nettools traceroute dnsutils wol iperf
    # filesystems
    zfs zfstools inotify-tools lsof parted ntfs3g gptfdisk
    # network filesystems
    nfs-utils
    # hard drive management
    lsscsi hddtemp hdparm perf-tools
    # security
    openssl
  ] ++ lib.optionals (!config.boot.loader.raspberryPi.enable) [
    gitAndTools.git-annex 
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

  # Nix Auto Garbage Collect
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 15";
  };
}
