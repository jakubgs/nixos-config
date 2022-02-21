{ lib, pkgs, config, ... }:

let
  inherit (lib) concatStringsSep mapAttrsToList;
  formatConfig = ip: fqdns: 
    concatStringsSep "\n" (map (fqdn: "address=/${fqdn}/${ip}") fqdns);

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

      conf-dir=/etc/dnsmasq.d/,*.conf
      conf-file=${blockedFqdns}/domains
      addn-hosts=${blockedFqdns}/hosts
    '';
  };

  # Support wildcard resolution of /etc/hosts contents.
  environment.etc."dnsmasq.d/hosts.conf" = {
    text = concatStringsSep "\n" (
      mapAttrsToList formatConfig config.networking.hosts
    );
  };
}
