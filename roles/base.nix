{ pkgs, ... }:

{
  imports = [
    ./nix.nix
    ./helpers.nix
    ./secrets.nix
    ./security.nix
  ];

  # Packages
  environment.systemPackages = with pkgs; [
    # utilities
    file zsh bash man-pages sudo pass bc pv rename uptimed
    # building
    gnumake gcc autoconf automake patchelf
    unrar unzip zip envsubst entr
    # processes
    dtach reptyr pstree killall
    # monitoring
    htop iotop iftop multitail
    # dev tools
    neovim jq tmux fzf silver-searcher
    git qrencode sqlite
    # hardware tools
    pciutils lm_sensors acpi pmutils usbutils dmidecode
    # networking
    wget curl nmap nettools traceroute dnsutils wol iperf
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
  networking.search = [ "magi.blue" "magi.lan" ];

  # NTP Server
  services.chrony.enable = true;

  # Uptime tracker
  services.uptimed.enable = true;
}
