{ lib, pkgs, ... }:

let
  genHostConfig = ip: paths: lib.concatStringsSep "\n" (
    map (p: "${p} -fstype=nfs,vers=4,async,noac,soft ${ip}:/mnt/${p}") paths
  );
in {
  services.autofs = {
    enable = true;
    timeout = 60;
    autoMaster =
      let
        melchiorConf = pkgs.writeText "autofs-melchior" (
          genHostConfig "melchior.magi.vpn" [
            "git" "data" "music" "photos" "backup" "torrent"
          ]
        );
        lelielConf = pkgs.writeText "autofs-leliel" (
          genHostConfig "leliel.magi.vpn" [
            "git" "data" "music" "photos" "torrent"
          ]
        );
      in ''
        /nfs/melchior ${melchiorConf} --timeout 30
        /nfs/leliel ${lelielConf} --timeout 30
      '';
  };
}
