{ pkgs ? import <nixpkgs> { }
, excludes ? [ "linkedin.com" ] }:

let
  inherit (pkgs) fetchurl;
  noTracking = "https://github.com/notracking/hosts-blocklists/raw/dfc5d3e1";
  stevenBlack = "https://github.com/StevenBlack/hosts/raw/3.6.3";
in pkgs.stdenv.mkDerivation {
  name = "dnsmasq-blocked-fqdns";

  # Lists for blocking ads, trackers, malware and other garbage.
  src = fetchurl {
    url = "${noTracking}/domains.txt";
    sha256 = "1xj4bipyy2crfc4dkhqnvfsfc2j6779n9gfqxnssr3xnza9mcrlc";
  };
  srcs = [
    (fetchurl { 
      url = "${noTracking}/hostnames.txt";
      sha256 = "004s4lk1an2gbklnc37rsxwqw6dh2d30x109kdzd99d6k05yyiwf";
    })
    (fetchurl { 
      url = "${stevenBlack}/alternates/fakenews-gambling-porn-social/hosts";
      sha256 = "14qvj3pywa6zq2nvsjll1c8kzjh8sdfaz0wflrm3wk10sv9nfvd1";
    })
  ];

  builder = pkgs.writeScript "dnsmasq-blocked-fqdns.sh" ''
    source $stdenv/setup
    mkdir $out

    cat $src \
      | grep -v -e '^\s*#' \
      > $out/domains

    cat $srcs \
      | grep -e '^0.0.0.0' \
      | grep -v -e ${pkgs.lib.concatStringsSep " -e " excludes} \
      | sort -u \
      > $out/hosts
  '';
}
