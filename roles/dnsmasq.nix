{ pkgs, ... }:

let
  blockedFqdns = pkgs.callPackage ../pkgs/blocked-fqdns.nix { };
in {
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    extraConfig = ''
      listen-address=127.0.0.1
      domain-needed
      bogus-priv
      cache-size=10000
      local-ttl=300

      conf-file=${blockedFqdns}/domains
      addn-hosts=${blockedFqdns}/hosts
    '';
  };
}
