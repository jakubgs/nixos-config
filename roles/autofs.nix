{ lib, pkgs, ... }:

let
  defaultOptions = "async,noac,soft,rsize=8192,wsize=8192";
  genHostConfig = ip: paths: lib.concatStringsSep "\n" (
    map (p: "${p} -fstype=nfs,vers=4,${defaultOptions} ${ip}:/mnt/${p}") paths
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
        sachielConf = pkgs.writeText "autofs-sachiel" (
          genHostConfig "sachiel.magi.vpn" [
            "git" "data" "music" "photos" "torrent"
          ]
        );
      in ''
        /nfs/melchior ${melchiorConf} --timeout 30
        /nfs/leliel ${lelielConf} --timeout 30
        /nfs/sachiel ${sachielConf} --timeout 30
      '';
  };
}
