{ pkgs, ... }:

{
  # Daemon
  services.locate = {
    enable = true;
    interval = "daily";
    prunePaths = [ "/mnt/torrent" ];
  };
}
