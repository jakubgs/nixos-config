{ pkgs ? import <nixpkgs> { }
, excludes ? [
  "groups.google.com"
  "linkedin.com" "licdn.com"
  "whatsapp.com"
  "redd"
] }:

let
  inherit (pkgs) fetchurl;
  noTracking = "https://github.com/notracking/hosts-blocklists/raw/ad8fd425";
  stevenBlack = "https://github.com/StevenBlack/hosts/raw/3.11.41";
in pkgs.stdenv.mkDerivation {
  name = "dnsmasq-blocked-fqdns";

  # Lists for blocking ads, trackers, malware and other garbage.
  src = fetchurl {
    url = "${noTracking}/domains.txt";
    sha256 = "sha256-MMYVBANe8YHPUGKg+gM1sfvNyqzk8jZOrcCZbglQHJw=";
  };
  srcs = [
    (fetchurl {
      url = "${noTracking}/hostnames.txt";
      sha256 = "sha256-u8JtxxgOgotCKfGFxdMj/7SNqRft1CwZVPzdwtz8p5I=";
    })
    (fetchurl {
      url = "${stevenBlack}/alternates/fakenews-gambling-porn-social/hosts";
      sha256 = "sha256-mqeH6nFr/J/w48FqePrmnvRsNsp3hFYbvkCsfyUS75s=";
    })
  ];

  builder = pkgs.writeScript "dnsmasq-blocked-fqdns.sh" ''
    source $stdenv/setup
    mkdir $out

    cat $src \
      | grep -v -e '^\s*#' \
      | grep -v -e ${pkgs.lib.concatStringsSep " -e " excludes} \
      > $out/domains

    cat $srcs \
      | grep -e '^0.0.0.0' \
      | grep -v -e ${pkgs.lib.concatStringsSep " -e " excludes} \
      | sort -u \
      > $out/hosts
  '';
}
