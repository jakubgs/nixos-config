{ pkgs, ... }:

let
  gtkSettings = ''
    [Settings]
    gtk-theme-name=Matcha-dark-azul
    gtk-icon-theme-name=hicolor
    gtk-font-name=Adwaita Sans 16
    gtk-cursor-theme-name=Adwaita
    gtk-cursor-theme-size=24
    gtk-application-prefer-dark-theme=true
  '';
in {
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme hicolor-icon-theme
    matcha-gtk-theme vimix-gtk-themes
  ];

  environment.sessionVariables = {
    GTK_THEME = "Matcha-dark-azul";
    XCURSOR_THEME = "Adwaita";
  };

  environment.etc."gtk-3.0/settings.ini".text = gtkSettings;
  environment.etc."gtk-4.0/settings.ini".text = gtkSettings;
}
