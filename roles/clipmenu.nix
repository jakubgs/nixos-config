{ ... }:

{
  # Enable clipboard manager
  services.clipmenu.enable = true;

  # Ignore my script for finding secrets
  systemd.user.services.clipmenu = {
    environment = {
      CM_DEBUG = "0";
      CM_MAX_CLIPS = "1000";
      CM_IGNORE_WINDOW = "fpass";
    };
  };
}
