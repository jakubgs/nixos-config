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
    windowManager.awesome.enable = true;
    displayManager.sddm.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Console
    rxvt_unicode rofi ranger
    # X Tools
    xkbset xorg.xmodmap xcape xbindkeys
    # System
    gparted
    # Desktop
    nitrogen arandr
    # Browsers
    brave chromium
    # Other
    xfce.thunar discord steam
    # Video player
    mpv
  ];

  fonts = {
    enableFontDir = true;
    fontconfig = {
      defaultFonts = {
        monospace = [ "terminus" ];
      };
    };
    fonts = with pkgs; [
      corefonts
      terminus_font
      terminus_font_ttf
      dejavu_fonts
      ubuntu_font_family
    ];
  };
}
