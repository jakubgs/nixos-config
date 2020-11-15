{ lib, pkgs, ... }:

let
  genHostConfig = ip: paths: lib.concatStringsSep "\n" (
    map (p: "${baseNameOf p} -fstype=nfs ${ip}:${p}") paths
  );
in {
  services.autofs = {
    enable = true;
    timeout = 60;
    autoMaster =
      let
        melchiorConf = pkgs.writeText "autofs-melchior" (
          genHostConfig "192.168.1.12" [
            "git" "data" "music" "photos" "backup" "torrent"
          ]
        );
        lelielConf = pkgs.writeText "autofs-leliel" (
          genHostConfig "leliel.magi.vpn" [
            "git" "data" "music" "photos" "torrent"
          ]
        );
      in ''
        /mnt/melchior ${melchiorConf}
        /mnt/leliel ${lelielConf}
      '';
  };
}
