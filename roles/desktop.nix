{ pkgs, lib, ... }:

{
  imports = [
    ./xserver.nix
    ./clipmenu.nix
  ];

  # Accept unfree licenses
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # Console
    rxvt_unicode ranger rofi
    # Xorg Tools
    glxinfo xsel libdrm xorg.xmodmap
    # Keyboard
    xcape xbindkeys xclip xkbset 
    # Network
    networkmanagerapplet
    # System
    gparted
    # Audio
    pavucontrol
    # Screen
    arandr
    # Security
    pinentry-gnome gnome3.seahorse cryptsetup
    # Phone
    jmtpfs
    chirp
  ];

  # User packages
  users.users.sochan.packages = with pkgs; [
    # Desktop
    xfce.thunar nitrogen scrot screenfetch flameshot
    # Themes
    lxappearance lounge-gtk-theme
    # Browsers
    brave chromium
    # Documents
    evince
    # Images
    feh gthumb gimp exiftool
    # Video
    mpv youtube-dl ffmpeg
    # Audio
    mpc_cli ncmpcpp vorbis-tools mpg321
    # Communication
    evolution protonmail-bridge discord
    # Torrent
    transmission-remote-gtk
    # Coding
    zeal
  ];

  # Keyring for app credentials
  services.gnome.gnome-keyring.enable = true;

  # Fix Evolution startup errors
  services.gnome.evolution-data-server.enable = true;

  # Fix Gnome Apps that require dconf
  programs.dconf.enable = true;
}
