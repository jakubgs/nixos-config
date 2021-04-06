{ lib, pkgs, ... }:

let
  baseUrl = "https://raw.githubusercontent.com/StevenBlack/hosts";
  commit = "358526ed7866d474c9158cb61f47c8aabedb8014";
  hostsFile = pkgs.fetchurl {
    url = "${baseUrl}/${commit}/alternates/fakenews-gambling-porn-social/hosts";
    sha256 = "1r408ynygh7vs6flh80h5k2214wzx6q8bmkrik9haidxa23x6fgs";
  };
  hostsContent = lib.readFile hostsFile;
in {
  networking.extraHosts = hostsContent + ''
    0.0.0.0 4chan.org
    0.0.0.0 4channel.org
    0.0.0.0 boards.4channel.org
    0.0.0.0 4cdn.org
  '';
}
