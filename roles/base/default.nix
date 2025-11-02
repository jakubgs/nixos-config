{ pkgs, lib, ... }:

{
  imports = [
    ./shell.nix
    ./console.nix
    ./fixes.nix
    ./helpers.nix
    ./landing.nix
    ./locate.nix
    ./nix.nix
    ./ntp.nix
    ./security.nix
    ./users.nix
    ./zerotier.nix
    ./zfs.nix
    ../metrics
  ];

  # Packages
  environment.systemPackages = with pkgs; [
    # utilities
    file bash man-pages sudo sd bc pv rename
    lsb-release moreutils unzip zip unrar envsubst
    # processes
    dtach pstree killall sysstat
    # monitoring
    htop btop iotop iftop s-tui multitail entr
    # dev tools
    jq tmux fzf silver-searcher git
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
}
