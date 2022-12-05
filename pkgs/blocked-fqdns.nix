{ pkgs ? import <nixpkgs> { }
, excludes ? [ "linkedin.com" "web.whatsapp.com" "pstmrk.it" ] }:

let
  inherit (pkgs) fetchurl;
  noTracking = "https://github.com/notracking/hosts-blocklists/raw/ce5c97a4";
  stevenBlack = "https://github.com/StevenBlack/hosts/raw/3.11.3";
in pkgs.stdenv.mkDerivation {
  name = "dnsmasq-blocked-fqdns";

  # Lists for blocking ads, trackers, malware and other garbage.
  src = fetchurl {
    url = "${noTracking}/domains.txt";
    sha256 = "sha256-LRg5f08nbcI5VMzM5rzEyp6NUrB7rnYHckFBxIjrpT8=";
  };
  srcs = [
    (fetchurl {
      url = "${noTracking}/hostnames.txt";
      sha256 = "sha256-UFa03ypTpZtWSBSV9Y0RHwK//5jXfKyefXPcX4mTW3Q=";
    })
    (fetchurl {
      url = "${stevenBlack}/alternates/fakenews-gambling-porn-social/hosts";
      sha256 = "sha256-OxCcZn54ayROZWZPJdadzjZCs7VEhr1RLDta0T67wrc=";
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
