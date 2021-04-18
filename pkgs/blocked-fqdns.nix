{ pkgs ? import <nixpkgs> { }
, excludes ? [ "linkedin.com" ] }:

pkgs.stdenv.mkDerivation {
  name = "dnsmasq-blocked-fqdns";

  # Lists for blocking ads, trackers, malware and other garbage.
  src = pkgs.fetchurl {
    url = "https://github.com/notracking/hosts-blocklists/raw/dfc5d3e1bc16c687a0e2a1d6bdf023cfa89574ec/domains.txt";
    sha256 = "1xj4bipyy2crfc4dkhqnvfsfc2j6779n9gfqxnssr3xnza9mcrlc";
  };
  srcs = [
    (pkgs.fetchurl { 
      url = "https://github.com/notracking/hosts-blocklists/raw/dfc5d3e1bc16c687a0e2a1d6bdf023cfa89574ec/hostnames.txt";
      sha256 = "004s4lk1an2gbklnc37rsxwqw6dh2d30x109kdzd99d6k05yyiwf";
    })
    (pkgs.fetchurl { 
      url = "https://github.com/StevenBlack/hosts/raw/3.6.3/alternates/fakenews-gambling-porn-social/hosts";
      sha256 = "14qvj3pywa6zq2nvsjll1c8kzjh8sdfaz0wflrm3wk10sv9nfvd1";
    })
  ];

  builder = pkgs.writeScript "dnsmasq-blocked-fqdns.sh" ''
    source $stdenv/setup
    mkdir $out
    cat $src | grep -v -e '^\s*#' > $out/domains
    cat $srcs | grep -v -e '^\s*#' -e '^::' \
      | grep -v ${pkgs.lib.concatStringsSep " -e " excludes} \
      | sort -u > $out/hosts
  '';
}
