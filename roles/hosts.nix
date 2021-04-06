{ lib, ... }:

let
  hostsUrls = [
    https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
    https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/gambling-porn-social/hosts
  ];
  hostsFiles = map builtins.fetchurl hostsUrls;
  hostsContents = map lib.readFile hostsFiles;
in {
  networking.extraHosts = lib.concatStringsSep "\n" (
    hostsContents ++ [
    ''
      0.0.0.0 4chan.org
      0.0.0.0 4channel.org
      0.0.0.0 boards.4channel.org
      0.0.0.0 4cdn.org
    ''
  ]);
}
