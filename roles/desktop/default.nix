{ pkgs, channels, ... }:

{
  imports = [
    ./autofs.nix
    ./bluetooth.nix
    ./clipmenu.nix
    ./crypto.nix
    ./dnsmasq.nix
    ./docker.nix
    ./docs.nix
    ./mime.nix
    ./music.nix
    ./network.nix
    ./physlock.nix
    ./redshift.nix
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
    glxinfo xsel libdrm xorg.xmodmap
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
    go-mtpfs chirp
  ];

  # User packages
  users.users.jakubgs.packages = with pkgs; [
    # Desktop
    xfce.thunar nitrogen scrot neofetch flameshot
    # Themes
    lxappearance matcha-gtk-theme vimix-gtk-themes
    # Browsers
    brave ungoogled-chromium
    # Documents
    evince foliate
    # Images
    feh qimgv gimp exiftool
    # Video
    mpv yt-dlp ffmpeg
    # Audio
    mpc_cli ncmpcpp vorbis-tools mpg123 soundconverter
    # Communication
    geary discord
    # Torrent
    transmission-remote-gtk
    # Coding
    zeal
  ];

  # Pipewire causes crackling
  services.pipewire.enable = false;
  hardware.pulseaudio.enable = true;

  # Automatically detect screen layout changes.
  services.autorandr.enable = true;

  # Fix Evolution startup errors
  services.gnome.evolution-data-server.enable = true;

  # Fix Gnome Apps that require dconf
  programs.dconf.enable = true;
}
