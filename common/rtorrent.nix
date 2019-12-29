{ ... }:

{
  # rtorrent
  services.rtorrent = {
    enable = true;
    user = "sochan";
    group = "sochan";
    dataDir = "/mnt/media/torrent";
    workDir = "/mnt/media/rtorrent";
    extraConfig = ''
      min_peers = 40
      max_peers = 1200
      max_uploads = 15
      download_rate = 10000
      upload_rate = 5000
      throttle.global_down.max_rate.set_kb = 9000
      throttle.global_up.max_rate.set_kb = 500
    '';
  };
}
