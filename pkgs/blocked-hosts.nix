{ pkgs ? import <nixpkgs> { }
, includes ? [
  "4channel.org" "4chan.org"
]
, excludes ? [
  "twitter" "twimg"
  "whatsapp.com" "whatsapp.net"
  "linkedin.com" "licdn.com"
  "groups.google.com" "pstmrk"
] }:

let
  inherit (pkgs) lib fetchurl;
  inherit (lib) concatStringsSep;
in pkgs.stdenv.mkDerivation {
  name = "dnsmasq-blocked-hosts";

  # Lists for blocking ads, trackers, malware and other garbage.
  src = fetchurl {
    url = "https://raw.githubusercontent.com/StevenBlack/hosts/3.14.99/alternates/fakenews-gambling-porn-social/hosts";
    sha256 = "sha256-qv1Z7F883oJGu7xnwpNfoEvkwOPEAJOMF0y483nmxOQ=";
  };

  builder = pkgs.writeScript "dnsmasq-blocked-hosts.sh" ''
    source $stdenv/setup
    mkdir $out

    cat $src \
      | grep -e '^0.0.0.0' \
      | grep -v -e ${concatStringsSep " -e " excludes} \
      | sort -u \
      > $out/hosts

    echo '${concatStringsSep "\n" (map (i: "0.0.0.0 " + i) includes)}' \
      >> $out/hosts
  '';
}
