{ pkgs, ... }:

let
  # Lists for blocking ads, trackers, malware and other garbage.
  noTrackUrl = "https://github.com/notracking/hosts-blocklists/raw/dfc5d3e1bc16c687a0e2a1d6bdf023cfa89574ec/";
  stevenUrl = "https://github.com/StevenBlack/hosts/raw/358526ed7866d474c9158cb61f47c8aabedb8014/";
  fetch = url: sha256: pkgs.fetchurl { inherit url sha256; };
in {
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    extraConfig = ''
      listen-address=::1,127.0.0.1
      domain-needed
      bogus-priv
      bind-interfaces
      cache-size=10000
      local-ttl=300

      conf-file=${fetch "${noTrackUrl}/domains.txt" "1xj4bipyy2crfc4dkhqnvfsfc2j6779n9gfqxnssr3xnza9mcrlc"}
      addn-hosts=${fetch "${noTrackUrl}/hostnames.txt" "004s4lk1an2gbklnc37rsxwqw6dh2d30x109kdzd99d6k05yyiwf"}
      addn-hosts=${fetch "${stevenUrl}/alternates/fakenews-gambling-porn-social/hosts" "1r408ynygh7vs6flh80h5k2214wzx6q8bmkrik9haidxa23x6fgs"}
    '';
  };
}
