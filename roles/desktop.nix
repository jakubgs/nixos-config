{ pkgs, ... }:

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
    displayManager.lightdm.enable = true;
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
    nitrogen arandr
    # Browsers
    brave chromium
    # Other
    xfce.thunar
    # Video
    mpv
    # Audio
    ncmpcpp
    # Communication
    gnome3.evolution discord zoom-us
    # Images
    feh gthumb
    # Gaming
    steam lutris
    # Torrent
    transmission-remote-gtk
    # Themes
    lxappearance arc-theme amber-theme
    # Remote
    remmina
    # Security
    pinentry-gtk2
  ];

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
