{ pkgs, ... }:

let
  # Lists for blocking ads, trackers, malware and other garbage.
  repoUrl = "https://github.com/notracking/hosts-blocklists";
  commit = "dfc5d3e1bc16c687a0e2a1d6bdf023cfa89574ec";
  fetch = file: sha256: pkgs.fetchurl {
    url = "${repoUrl}/raw/${commit}/${file}.txt";
    inherit sha256;
  };
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

      conf-file=${fetch "domains" "1xj4bipyy2crfc4dkhqnvfsfc2j6779n9gfqxnssr3xnza9mcrlc"}
      addn-hosts=${fetch "hostnames" "004s4lk1an2gbklnc37rsxwqw6dh2d30x109kdzd99d6k05yyiwf"}
    '';
  };
}
