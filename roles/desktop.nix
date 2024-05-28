{ pkgs, channels, ... }:

{
  imports = [
    ./xserver.nix
    ./clipmenu.nix
    ./redshift.nix
    ../services/protonmail-bridge.nix
  ];

  # Accept unfree licenses
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # Console
    rxvt_unicode rofi w3m
    # Xorg Tools
    glxinfo xsel libdrm xorg.xmodmap
    # Keyboard & Mouse
    xcape xbindkeys xclip xkbset
    # Network
    networkmanagerapplet
    # System
    gparted
    # Audio
    pavucontrol pasystray
    # Screen
    arandr
    # Security
    pinentry-gnome gnome3.seahorse cryptsetup
    # Phone
    go-mtpfs chirp
  ];

  # User packages
  users.users.jakubgs.packages = with pkgs; [
    # Desktop
    xfce.thunar nitrogen scrot screenfetch flameshot
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
    mpc_cli ncmpcpp vorbis-tools mpg321 soundconverter
    # Archive
    unrar
    # Communication
    gnome3.geary discord
    # Torrent
    transmission-remote-gtk
    # Coding
    zeal
  ];

  # Automatically detect screen layout changes.
  services.autorandr.enable = true;

  # Enable service that bridges SMTP with ProtonMail
  services.protonmail-bridge.enable = true;

  # Keyring for app credentials
  services.gnome.gnome-keyring.enable = true;

  # Fix Evolution startup errors
  services.gnome.evolution-data-server.enable = true;

  # Fix Gnome Apps that require dconf
  programs.dconf.enable = true;

  # Set Brave as default browser
  xdg.mime = {
    enable = true;
    defaultApplications = {
      "text/html"                = "brave.desktop";
      "x-scheme-handler/http"    = "brave.desktop";
      "x-scheme-handler/https"   = "brave.desktop";
      "x-scheme-handler/about"   = "brave.desktop";
      "x-scheme-handler/unknown" = "brave.desktop";
    };
  };
}
