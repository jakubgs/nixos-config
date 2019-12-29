{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common/users.nix
    ../../common/samba.nix
    ../../common/music.nix
    ../../common/zerotier.nix
  ];

  # Modules for sensors
  boot.kernelModules = [ "it87" "k10temp" ];

  # Enable ZFS support
  networking.hostId = "e5acabaa";
  boot.supportedFilesystems = [ "zfs" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.device = "/dev/sdh";
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub.useOSProber = false;

  networking.hostName = "melchior";
  networking.domain = "magi";
  networking.interfaces.enp3s0.useDHCP = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Packages installed in system profile
  environment.systemPackages = with pkgs; [
    # utilities
    zsh wget curl multitail
    # dev tools
    git neovim jq tmux fzf
    # hardware tools
    pciutils htop lm_sensors
    # networking
    nmap nettools
    # filesystems
    zfs zfstools 
    # hard drive management
    smartmontools lsscsi hddtemp hdparm
  ];

  # Default editor
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # Security
  programs.mtr.enable = true;
  programs.zsh.enable = true;
  services.openssh.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # SMART drive monitoring
  services.smartd = {
    enable = true;
    autodetect = true;
  };

  # Open ports in the firewall.
  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Determines the NixOS release with which your system is to be compatible
  # You should change this only after NixOS release notes say you should.
  system.stateVersion = "19.09";
}
