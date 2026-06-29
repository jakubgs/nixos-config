{ pkgs, ... }:

{
  imports = [
    ./autofs.nix
    ./bluetooth.nix
    ./clipmenu.nix
    ./dnsmasq.nix
    ./docker.nix
    ./docs.nix
    ./mime.nix
    ./music.nix
    ./network.nix
    ./physlock.nix
    ./xserver.nix
    ./yubikey.nix
  ];

  # Accept unfree licenses
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # Console
    rxvt-unicode rofi w3m
    # Xorg Tools
    xsel libdrm xmodmap xcalib
    # Keyboard & Mouse
    xcape xbindkeys xclip xkbset
    # Network
    networkmanagerapplet
    # System
    gparted
    # Audio
    pavucontrol pamix pasystray
    # Screen
    arandr
    # Security
    cryptsetup
    # Phone
    go-mtpfs
  ];

  # User packages
  users.users.jakubgs.packages = with pkgs; [
    # Desktop
    thunar nitrogen scrot flameshot
    # Themes
    lxappearance matcha-gtk-theme vimix-gtk-themes
    # Browsers
    brave
    # Documents
    evince foliate
    # Images
    feh qimgv gimp exiftool
    # Video
    mpv yt-dlp ffmpeg
    # Audio
    vorbis-tools mpg123 soundconverter pulsemixer
    # Communication
    discord
    # Torrent
    transmission-remote-gtk
    # Coding
    zeal
  ];

  # Pipewire causes crackling
  services.pipewire.enable = false;
  services.pulseaudio.enable = true;

  # Automatically detect screen layout changes.
  services.autorandr.enable = true;

  # Fix Evolution startup errors
  services.gnome.evolution-data-server.enable = true;

  # Fix Gnome Apps that require dconf
  programs.dconf.enable = true;
}
