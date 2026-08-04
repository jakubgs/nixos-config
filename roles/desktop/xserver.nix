{ pkgs, ... }:

let
  disableAccelProfile = name:
    "xinput set-prop 'pointer:${name}' 'Device Accel Profile' -1";
in {
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    # Remap Caps Lock to Control.
    xkb.options = "ctrl:nocaps";
    xkb.layout = "pl";
    enableCtrlAltBackspace = true;
    displayManager = {
      lightdm = {
        enable = true;
        background = "${../../files/wallpapers/default.jpg}";
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

  # Necessary for corefonts
  nixpkgs.config.allowUnfree = true;
}
