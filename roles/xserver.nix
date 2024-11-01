{ pkgs, ... }:

let
  disableAccelProfile = name:
    "xinput set-prop 'pointer:${name}' 'Device Accel Profile' -1";
in {
  services.displayManager.defaultSession = "none+awesome";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    xkb.layout = "pl";
    enableCtrlAltBackspace = true;
    windowManager.awesome.enable = true;
    displayManager = {
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
    packages = with pkgs; [
      inconsolata
      terminus_font
      corefonts
      fira-code
      dejavu_fonts
      ubuntu_font_family
    ];
  };

  # Necessary for corefonts
  nixpkgs.config.allowUnfree = true;
}
