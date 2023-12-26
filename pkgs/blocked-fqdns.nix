{ pkgs ? import <nixpkgs> { }
, includes ? [
  "4channel.org" "4chan.org"
]
, excludes ? [
  "twitter" "twimg"
  "whatsapp.com" "redd"
  "linkedin.com" "licdn.com"
  "groups.google.com" "pstmrk"
] }:

let
  inherit (pkgs) lib fetchurl;
  inherit (lib) concatStringsSep;

  noTracking = "https://github.com/notracking/hosts-blocklists/raw/2ab426e8";
  stevenBlack = "https://github.com/StevenBlack/hosts/raw/3.14.41";
in pkgs.stdenv.mkDerivation {
  name = "dnsmasq-blocked-fqdns";

  # Lists for blocking ads, trackers, malware and other garbage.
  src = fetchurl {
    url = "${noTracking}/domains.txt";
    sha256 = "sha256-6I6opvozJUMHqkJXhyHyZEqnfy1hziTXCGqZm+eVXXc=";
  };
  srcs = [
    (fetchurl {
      url = "${noTracking}/hostnames.txt";
      sha256 = "sha256-z5k0upPaFTCKO9cJ/5zLGuDwzXAbw7pReFaLVLt1LXM=";
    })
    (fetchurl {
      url = "${stevenBlack}/alternates/fakenews-gambling-porn-social/hosts";
      sha256 = "sha256-Qg5kT1Ct+K3TUetA24SG7+1LOLtpBBufm9ZKoaUbcWQ=";
    })
  ];

  builder = pkgs.writeScript "dnsmasq-blocked-fqdns.sh" ''
    source $stdenv/setup
    mkdir $out

    cat $src \
      | grep -v -e '^\s*#' \
      | grep -v -e ${concatStringsSep " -e " excludes} \
      > $out/domains

    cat $srcs \
      | grep -e '^0.0.0.0' \
      | grep -v -e ${concatStringsSep " -e " excludes} \
      | sort -u \
      > $out/hosts

    echo '${concatStringsSep "\n" (map (i: "0.0.0.0 " + i) includes)}' \
      >> $out/hosts
  '';
}
