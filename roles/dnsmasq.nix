{ lib, pkgs, config, ... }:

let
  inherit (lib) concatStringsSep mapAttrsToList optionalAttrs;

  stubbyEnabled = true;

  stubbyExample = pkgs.stubby.passthru.settingsExample;
  blockedHosts = pkgs.callPackage ../pkgs/blocked-hosts.nix { };

  formatConfig = ip: fqdns:
    concatStringsSep "\n" (map (fqdn: "address=/${fqdn}/${ip}") fqdns);
in {
  # DNS over TLS
  services.stubby = {
    enable = stubbyEnabled;
    logLevel = "info";
    settings = stubbyExample // {
      listen_addresses = [ "127.0.1.153:53" ];
      dnssec_return_status = "GETDNS_EXTENSION_TRUE";
      upstream_recursive_servers = [
        {
          address_data = "1.1.1.1";
          tls_auth_name = "cloudflare-dns.com";
          tls_pubkey_pinset = [
            { digest = "sha256"; value = "4pqQ+yl3lAtRvKdoCCUR8iDmA53I+cJ7orgBLiF08kQ="; }
          ];
        }
        {
          address_data = "1.0.0.1";
          tls_auth_name = "cloudflare-dns.com";
          tls_pubkey_pinset = [
            { digest = "sha256"; value = "4pqQ+yl3lAtRvKdoCCUR8iDmA53I+cJ7orgBLiF08kQ="; }
          ];
        }
        {
          address_data = "8.8.8.8";
          tls_auth_name = "dns.google";
          tls_pubkey_pinset = [
            { digest = "sha256"; value = "pjKe8bAOKqjEHNl0n9VF4FuVY5jVrDUn1vMSWiZkRzA="; }
          ];
        }
      ];
    };
  };

  # DNS Domain Filtering
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    settings = {
      interface = "lo";
      bind-interfaces = true;
      no-negcache = true;
      cache-size = 10000;
      local-ttl = 300;
      local = "/magi.lan/";
      conf-dir = "/etc/dnsmasq.d/,*.conf";
      addn-hosts = "${blockedHosts}/hosts";
    } // optionalAttrs stubbyEnabled {
      strict-order = true;
      proxy-dnssec = true;
      server = ["127.0.1.153"];
    };
  };

  # Support wildcard resolution of /etc/hosts contents.
  environment.etc."dnsmasq.d/hosts.conf" = {
    text = concatStringsSep "\n" (
      mapAttrsToList formatConfig config.networking.hosts
    );
  };
}
