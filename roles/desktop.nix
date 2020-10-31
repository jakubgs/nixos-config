{ pkgs, lib, ... }:

let
  disableAccelProfile = name:
    "xinput set-prop 'pointer:${name}' 'Device Accel Profile' -1";
in {
  # Accept unfree licenses
  nixpkgs.config.allowUnfree = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "pl";
    videoDrivers = [ "intel" "nvidia" ];
    enableCtrlAltBackspace = true;
    windowManager.awesome.enable = true;
    displayManager = {
      defaultSession = "none+awesome";
      lightdm = {
        enable = true;
        background = "${../files/wallpapers/default.jpg}";
      };
      # for better mouse in FPS
      # TODO: generalize for all pointers with this setting
      sessionCommands = ''
        ${disableAccelProfile "Razer Razer DeathAdder Elite"}
        ${disableAccelProfile "Razer Razer DeathAdder Elite Consumer Control"}
      '';
    };
    # symlink at /etc/X11/xorg.conf
    exportConfiguration = true;
  };

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
    pinentry-gtk2 cryptsetup
    gnome3.seahorse
    # Phone
    jmtpfs
    chirp
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
    mpc_cli ncmpcpp vorbis-tools mpg321
    # Communication
    gnome3.geary discord
    # Torrent
    transmission-remote-gtk
    # Coding
    zeal
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
      corefonts terminus_font
      fira-code inconsolata
      dejavu_fonts ubuntu_font_family
    ];
  };

  # Keyring for app credentials
  services.gnome3.gnome-keyring.enable = true;

  # Fix Gnome Apps that require dconf
  programs.dconf.enable = true;
}
