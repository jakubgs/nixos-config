{ pkgs, lib, ... }:

{
  # Accept unfree licenses
  nixpkgs.config.allowUnfree = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "pl";
    videoDrivers = [ "nvidia" ];
    enableCtrlAltBackspace = true;
    windowManager.awesome.enable = true;
    displayManager.lightdm = {
      enable = true;
      background = "${../files/wallpapers/default.jpg}";
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    # Console
    rxvt_unicode ranger rofi
    # X Tools
    xclip xkbset xorg.xmodmap xcape xbindkeys glxinfo xsel
    # Network
    networkmanagerapplet
    # System
    gparted
    # Desktop
    arandr
    # Security
    pinentry-gtk2
  ];

  # User packages
  users.users.sochan.packages = with pkgs; [
    # Desktop
    xfce.thunar nitrogen scrot
    # Themes
    lxappearance lounge-gtk-theme
    # Browsers
    brave chromium
    # Documents
    evince
    # Images
    feh gthumb
    # Video
    mpv youtube-dl
    # Audio
    ncmpcpp vorbis-tools mpg321
    # Communication
    gnome3.evolution discord zoom-us
    # Torrent
    transmission-remote-gtk
  ];

  # Tonts
  fonts = {
    fontconfig = {
      cache32Bit = true;
      allowBitmaps = true;
      useEmbeddedBitmaps = true;
      defaultFonts = {
        monospace = [ "terminus" ];
      };
    };
    fonts = with pkgs; [
      corefonts
      terminus_font
      dejavu_fonts
      ubuntu_font_family
    ];
  };

  # Keyring for app credentials
  services.gnome3.gnome-keyring.enable = true;
}
