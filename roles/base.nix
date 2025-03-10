{ pkgs, lib, ... }:

{
  imports = [
    ./nix.nix
    ./fixes.nix
    ./console.nix
    ./helpers.nix
    ./security.nix
    ./metrics
  ];

  # Packages
  environment.systemPackages = with pkgs; [
    # utilities
    file zsh bash man-pages sudo bc pv rename
    lsb-release moreutils unzip zip envsubst
    # processes
    dtach pstree killall sysstat
    # monitoring
    htop btop iotop iftop s-tui multitail entr
    # dev tools
    neovim jq tmux fzf silver-searcher git
    # hardware tools
    pciutils lm_sensors acpi pmutils usbutils dmidecode
    # networking
    wget curl nmap nettools traceroute dnsutils iperf
    # filesystems
    ncdu zfs zfstools ranger lsof ntfs3g nfs-utils
    # hard drive management
    lsscsi hddtemp hdparm perf-tools parted gptfdisk
    # security
    pass gopass
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
  networking = {
    enableIPv6 = false;
    domain = lib.mkDefault "magi.lan";
    search = [ "magi.lan" ];
  };

  # Uptime tracker
  services.uptimed.enable = true;
}
