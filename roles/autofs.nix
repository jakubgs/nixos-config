{ lib, pkgs, ... }:

let
  hostShares = {
    "melchior.magi.vpn" = [ "git" "data" "music" "photos" "torrent" "backup" ];
    "sachiel.magi.vpn" =  [ "git" "data" "music" "photos" "torrent" ];
    "leliel.magi.vpn" =   [ "git" "data" "music" "photos" "torrent" ];
  };

  defaultNfsOptions = "async,noac,soft,rsize=262144,wsize=262144";
  genNfsShare = addr: paths:
    lib.concatStringsSep "\n" (
      map (p: "${p} -fstype=nfs,${defaultNfsOptions} ${addr}:/mnt/${p}") paths
    );

  defaultCifsOptions = "rw,credentials=/home/sochan/.smbcredentials";
  genCifsShare = addr: paths:
    lib.concatStringsSep "\n" (
      map (p: "${p} -fstype=cifs,${defaultCifsOptions} ://${addr}/${p}") paths
    );

  genShareConfigFile = addr: genFunc:
    pkgs.writeText "autofs-${addr}" (genFunc addr (builtins.getAttr addr hostShares));
in {
  environment.systemPackages = with pkgs; [ cifs-utils ];

  services.autofs = {
    enable = true;
    timeout = 60;
    autoMaster = ''
      #/nfs/melchior  ${genShareConfigFile "melchior.magi.vpn" genNfsShare}  --timeout 3
      #/nfs/leliel    ${genShareConfigFile "leliel.magi.vpn"   genNfsShare}  --timeout 3
      /nfs/sachiel   ${genShareConfigFile "sachiel.magi.vpn"  genNfsShare}  --timeout 3
      #/cifs/melchior ${genShareConfigFile "melchior.magi.vpn" genCifsShare} --timeout 3
      #/cifs/leliel   ${genShareConfigFile "leliel.magi.vpn"   genCifsShare} --timeout 3
      /cifs/sachiel  ${genShareConfigFile "sachiel.magi.vpn"  genCifsShare} --timeout 3
    '';
  };
}
