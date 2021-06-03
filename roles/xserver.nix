{ pkgs, ... }:

let
  # Necessary to fix broken Inconsolata font
  # https://github.com/googlefonts/Inconsolata/issues/42
  oldPackages = import (pkgs.fetchzip {
    url = "https://github.com/NixOS/nixpkgs/archive/47e580e291ff40bbde191e9fed35128727963b0c.zip";
    sha256 = "1fnz42w2p6avnz76p8n0dr2lvdgv1v1kipysih61mdakr4lc2fs8";
  }) { };
  disableAccelProfile = name:
    "xinput set-prop 'pointer:${name}' 'Device Accel Profile' -1";
in {
  # Font/DPI optimized for HiDPI displays
  hardware.video.hidpi.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "pl";
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

  # Fonts
  fonts = {
    fontconfig = {
      cache32Bit = true;
      allowBitmaps = true;
      useEmbeddedBitmaps = true;
      defaultFonts = {
        monospace = [ "Inconsolata" ];
      };
    };
    fonts = with pkgs; [
      terminus_font oldPackages.inconsolata
      corefonts fira-code dejavu_fonts ubuntu_font_family
    ];
  };
}
