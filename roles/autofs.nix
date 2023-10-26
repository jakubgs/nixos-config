{ lib, pkgs, ... }:

let
  hostShares = {
    #"leliel" =  [ "git" "data" "music" "photos" ];
    "bardiel" = [ "git" "data" "music" "photos" ];
    "sachiel" = [ "git" "data" "music" "photos" "torrent" ];
    "arael" =   [ "git" "data" "music" "photos" "torrent" ];
  };

  defaultNfsOptions = "async,noac,soft,rsize=262144,wsize=262144";
  genNfsShare = host: paths:
    lib.concatStringsSep "\n" (
      map (p: "${p} -fstype=nfs,${defaultNfsOptions} ${host}.magi.vpn:/mnt/${p}") paths
    );

  defaultCifsOptions = "uid=1000,gid=1000,rw,credentials=/home/jakubgs/.smbcredentials";
  genCifsShare = host: paths:
    lib.concatStringsSep "\n" (
      map (p: "${p} -fstype=cifs,${defaultCifsOptions} ://${host}.magi.vpn/${p}") paths
    );

  genShareConfigFile = host: shares: genFunc:
    pkgs.writeText "autofs-${host}" (genFunc host shares);
in {
  environment.systemPackages = with pkgs; [ cifs-utils ];

  services.autofs = {
    enable = true;
    timeout = 60;
    autoMaster =
      lib.concatStrings (lib.mapAttrsToList (host: shares: ''
        /nfs/${host}  ${genShareConfigFile host shares genNfsShare}  --timeout 3
      '') hostShares) +
      lib.concatStrings (lib.mapAttrsToList (host: shares: ''
        /cifs/${host} ${genShareConfigFile host shares genCifsShare} --timeout 3
      '') hostShares);
  };
}
