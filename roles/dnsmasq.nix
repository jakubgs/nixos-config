{ lib, pkgs, config, ... }:

let
  inherit (lib) concatStringsSep mapAttrsToList;
  formatConfig = ip: fqdns: 
    concatStringsSep "\n" (map (fqdn: "address=/${fqdn}/${ip}") fqdns);

  stubbyExample = pkgs.stubby.passthru.settingsExample;

  blockedFqdns = pkgs.callPackage ../pkgs/blocked-fqdns.nix { };
in {
  # DNS over TLS
  services.stubby = {
    enable = true;
    settings = stubbyExample // {
      listen_addresses = [ "127.0.0.1:153" ];
      log_level = "GETDNS_LOG_NOTICE";
      dnssec_return_status = "GETDNS_EXTENSION_TRUE";
      upstream_recursive_servers = stubbyExample.upstream_recursive_servers ++ [
        {
          address_data = "1.1.1.1";
          tls_port = 853;
          tls_auth_name = "cloudflare-dns.com";
          tls_pubkey_pinset = [
            { digest = "sha256";
              value = "MnLdGiqUGYhtyinlrGTC4FZdDyDXv4NOWFGnXW3ur14="; }
          ];
        }
      ];
    };
  };

  # DNS Domain Filtering
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    extraConfig = ''
      listen-address=127.0.0.1
      interface=lo
      cache-size=10000
      local-ttl=300

      no-resolv
      server=127.0.0.1#153

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
