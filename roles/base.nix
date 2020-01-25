{ pkgs, lib, ... }:

{
  # Packages
  environment.systemPackages = with pkgs; [
    # utilities
    file zsh bash wget curl manpages sudo pass bc rename
    # building
    gnumake unzip zip envsubst entr
    # processes
    dtach reptyr pstree
    # monitoring
    htop iotop iftop multitail
    # dev tools
    neovim jq tmux fzf silver-searcher
    git gitAndTools.git-annex qrencode
    # hardware tools
    pciutils lm_sensors acpi pmutils
    # networking
    nmap nettools traceroute dnsutils wol
    # filesystems
    zfs zfstools inotify-tools lsof parted ntfs3g gptfdisk
    # network filesystems
    nfs-utils
    # hard drive management
    smartmontools lsscsi hddtemp hdparm
    # security
    (if builtins.hasAttr "pinentry-curses" pkgs then
      lib.getAttr "pinentry-curses" pkgs else
      lib.getAttr "pinentry_ncurses" pkgs)
  ];

  # Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Editor
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # SMART drive monitoring
  services.smartd = {
    enable = true;
    autodetect = true;
  };

  # nobody cares about ipv6
  boot.kernelParams = [ "ipv6.disable=1" ];
  networking.enableIPv6 = false;

  # domain use for my own infra
  networking.search = [ "magi.blue" ];
}
