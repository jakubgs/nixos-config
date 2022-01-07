{ pkgs, ... }:

let
  blockedFqdns = pkgs.callPackage ../pkgs/blocked-fqdns.nix { };
in {
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    servers = [
      "1.1.1.1"
      "8.8.8.8"
      "8.8.4.4"
    ];
    extraConfig = ''
      listen-address=127.0.0.1
      interface=lo
      bogus-priv
      cache-size=10000
      local-ttl=300

      conf-file=${blockedFqdns}/domains
      addn-hosts=${blockedFqdns}/hosts
    '';
  };
}
