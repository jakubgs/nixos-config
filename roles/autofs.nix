{ lib, pkgs, ... }:

let
  hostShares = {
    "melchior.magi.vpn" = [ "git" "data" "music" "photos" "torrent" "backup" ];
    "sachiel.magi.vpn" =  [ "git" "data" "music" "photos" "torrent" ];
    "leliel.magi.vpn" =   [ "git" "data" "music" "photos" "torrent" ];
  };

  defaultOptions = "async,noac,soft,rsize=262144,wsize=262144";
  genNfsShare = addr: paths:
    lib.concatStringsSep "\n" (
      map (p: "${p} -fstype=nfs,${defaultOptions} ${addr}:/mnt/${p}") paths
    );
  genShareConfigFile = addr: genFunc:
    pkgs.writeText "autofs-${addr}" (genFunc addr (builtins.getAttr addr hostShares));
in {
  services.autofs = {
    enable = true;
    timeout = 60;
    autoMaster = ''
      /nfs/melchior ${genShareConfigFile "melchior.magi.vpn" genNfsShare} --timeout 3
      /nfs/sachiel  ${genShareConfigFile "sachiel.magi.vpn"  genNfsShare} --timeout 3
      /nfs/leliel   ${genShareConfigFile "leliel.magi.vpn"   genNfsShare} --timeout 3
    '';
  };
}
