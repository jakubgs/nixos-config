{ pkgs, ... }:

{
  imports = [
    ./nix.nix
    ./fixes.nix
    ./console.nix
    ./helpers.nix
    ./metrics.nix
    ./security.nix
  ];

  # Packages
  environment.systemPackages = with pkgs; [
    # utilities
    file zsh bash man-pages sudo bc pv rename
    uptimed lsb-release moreutils
    # building
    gnumake gcc autoconf automake patchelf
    unzip zip envsubst entr
    # processes
    dtach pstree killall sysstat
    # monitoring
    htop iotop iftop multitail
    # dev tools
    neovim jq tmux pkgs.unstable.fzf silver-searcher
    git qrencode sqlite
    # hardware tools
    pciutils lm_sensors acpi pmutils usbutils dmidecode
    # networking
    wget curl nmap nettools traceroute dnsutils wol iperf
    # filesystems
    ncdu zfs zfstools ranger lsof ntfs3g
    # hard drive management
    lsscsi hddtemp hdparm perf-tools parted gptfdisk
    # network filesystems
    nfs-utils
    # security
    pass gopass openssl
  ];

  # Shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Editor
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  # Editor
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  boot.kernel.sysctl = {
    # SysRQ is useful when things hang.
    "kernel.sysrq" = 1;
    # Reclaim file pages as often as anon pages.
    "vm.swappiness" = 100;
  };

  # domain use for my own infra
  networking.search = [ "magi.blue" "magi.lan" ];

  # NTP Server
  services.chrony.enable = true;

  # Uptime tracker
  services.uptimed.enable = true;
}
