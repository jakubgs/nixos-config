{ pkgs, lib, ... }:

{
  # Simple desktop
  services.xserver = {
    enable = true;
    windowManager.icewm.enable = true;
    displayManager.lightdm.enable = true;
  };
  services.displayManager = {
    enable = true;
    defaultSession = "none+icewm";
    autoLogin.enable = true;
    autoLogin.user = "jakubgs";
  };

  # Fonts
  fonts = {
    fontconfig.defaultFonts.monospace = [ "Terminus" ];
    packages = with pkgs; [ terminus_font ];
  };
  environment.etc."X11/Xresources".text = ''
    *.font: xft:Terminus:size=15
  '';
  services.xserver.displayManager.sessionCommands = ''
    xrdb -merge /etc/X11/Xresources
  '';

  # Password entry method.
  programs.gnupg.agent.pinentryPackage = lib.mkForce pkgs.pinentry-curses;
}
