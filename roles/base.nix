{ pkgs, ... }:

{
  # Packages
  environment.systemPackages = with pkgs; [
    # utilities
    zsh bash wget curl manpages sudo
    # processes
    dtach reptyr pstree
    # monitoring
    htop iotop iftop multitail
    # dev tools
    neovim jq tmux fzf silver-searcher
    git gitAndTools.git-annex
    # hardware tools
    pciutils lm_sensors acpi
    # networking
    nmap nettools traceroute dnsutils wol
    # filesystems
    zfs zfstools inotify-tools lsof parted
    # network filesystems
    nfs-utils
    # hard drive management
    smartmontools lsscsi hddtemp hdparm
    # security
    pinentry-curses 
  ];

  # Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Editor
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Security
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  services.openssh.enable = true;
  services.openssh.openFirewall = true;
  services.openssh.passwordAuthentication = false;
  security.pam.enableSSHAgentAuth = true;

  # SMART drive monitoring
  services.smartd = {
    enable = true;
    autodetect = true;
  };

}
