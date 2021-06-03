{ lib, pkgs, ... }:

let
  defaultOptions = "async,noac,soft,rsize=262144,wsize=262144";
  genHostConfig = ip: paths:
    lib.concatStringsSep "\n" (
      map (p: "${p} -fstype=nfs,${defaultOptions} ${ip}:/mnt/${p}") paths
    );
in {
  services.autofs = {
    enable = true;
    timeout = 60;
    autoMaster =
      let
        melchior = pkgs.writeText "autofs-melchior" (
          genHostConfig "melchior.magi.vpn" [
            "git" "data" "music" "photos" "torrent" "backup"
          ]
        );
        leliel = pkgs.writeText "autofs-leliel" (
          genHostConfig "leliel.magi.vpn" [
            "git" "data" "music" "photos" "torrent"
          ]
        );
        sachiel = pkgs.writeText "autofs-sachiel" (
          genHostConfig "sachiel.magi.vpn" [
            "git" "data" "music" "photos" "torrent"
          ]
        );
      in ''
        /nfs/melchior ${melchior} --timeout 3
        /nfs/sachiel  ${sachiel}  --timeout 3
        /nfs/leliel   ${leliel}   --timeout 3
      '';
  };
}
