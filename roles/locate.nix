{ pkgs, ... }:

{
  # Daemon
  services.locate.enable = true;
  services.locate.locate = pkgs.mlocate;
  services.locate.interval = "daily";
  services.locate.prunePaths = [ "/mnt/torrent" ];
  services.locate.localuser = null; # Fix user warning
}
