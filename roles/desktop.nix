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

  # Enable 32bit OpenGL and PulseAudio
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;

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
    nitrogen arandr scrot
    # Browsers
    brave chromium
    # Other
    xfce.thunar
    # Documents
    evince
    # Video
    mpv python38Packages.youtube-dl
    # Audio
    ncmpcpp vorbis-tools mpg321
    # Communication
    gnome3.evolution discord zoom-us
    # Images
    feh gthumb
    # Gaming
    steam lutris
    # Torrent
    transmission-remote-gtk
    # Themes
    lxappearance lounge-gtk-theme
    # Remote
    remmina
    # Security
    pinentry-gtk2
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
