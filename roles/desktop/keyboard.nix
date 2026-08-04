{
  # Used by virtual console through console.useXkbConfig and any X11 sessions.
  services.xserver.xkb = {
    layout = "pl";
    options = "ctrl:nocaps";
  };

  # Fallback for Wayland compositors/toolkits using libxkbcommon defaults.
  # somewm can override this in rc.lua with awful.input.xkb_* settings.
  environment.sessionVariables = {
    XKB_DEFAULT_LAYOUT = "pl";
    XKB_DEFAULT_OPTIONS = "ctrl:nocaps";
  };

  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main.rightcontrol = "overload(control, esc)";
    };
  };
}
