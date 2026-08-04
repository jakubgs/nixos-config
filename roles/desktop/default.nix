{ pkgs, wrapWithFlags, ... }:

{
  imports = [
    ./autofs.nix
    ./audio.nix
    ./bluetooth.nix
    ./clipmenu.nix
    ./dnsmasq.nix
    ./docker.nix
    ./docs.nix
    ./fonts.nix
    ./themes.nix
    ./terminal.nix
    ./keyboard.nix
    ./mime.nix
    ./music.nix
    ./network.nix
    ./physlock.nix
    ./wayland.nix
    ./yubikey.nix
  ];

  # Accept unfree licenses
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # Console
    foot rofi w3m
    # Wayland Tools
    libdrm wl-clipboard wlr-randr
    # Network
    networkmanagerapplet
    # System
    gparted
    # Audio
    pavucontrol pamix
    # Screen
    grim slurp swappy brightnessctl
    # Security
    cryptsetup
    # Phone
    go-mtpfs
  ];

  # User packages
  users.users.jakubgs.packages = with pkgs; [
    # Desktop
    thunar swaybg grim slurp flameshot
    # Browsers
    (wrapWithFlags brave ["--force-device-scale-factor=1.30"])
    # Documents
    evince foliate
    # Images
    (wrapWithFlags qimgv ["-platform" "wayland"])
    feh gimp exiftool
    # Video
    mpv yt-dlp ffmpeg
    # Audio
    vorbis-tools mpg123 soundconverter pulsemixer
    # Communication
    (wrapWithFlags discord ["--ozone-platform=wayland"])
    # Torrent
    transmission-remote-gtk
    # Coding
    zeal
  ];

  # Fix Evolution startup errors
  services.gnome.evolution-data-server.enable = true;

  # Fix Gnome Apps that require dconf
  programs.dconf.enable = true;
}
