{ lib, pkgs, config, ... }:

let
  inherit (lib) concatStringsSep mapAttrsToList;

  stubbyEnabled = false;

  stubbyExample = pkgs.stubby.passthru.settingsExample;
  blockedFqdns = pkgs.callPackage ../pkgs/blocked-fqdns.nix { };

  formatConfig = ip: fqdns:
    concatStringsSep "\n" (map (fqdn: "address=/${fqdn}/${ip}") fqdns);
in {
  # DNS over TLS
  services.stubby = {
    enable = stubbyEnabled;
    settings = stubbyExample // {
      listen_addresses = [ "127.0.0.1:153" ];
      log_level = "GETDNS_LOG_NOTICE";
      dnssec_return_status = "GETDNS_EXTENSION_TRUE";
      upstream_recursive_servers = [
        { address_data = "1.1.1.1";
          tls_port = 853;
          tls_auth_name = "cloudflare-dns.com";
          tls_pubkey_pinset = [
            { digest = "sha256";
              value = "MnLdGiqUGYhtyinlrGTC4FZdDyDXv4NOWFGnXW3ur14="; }
          ]; }
        { address_data = "8.8.8.8";
          tls_port = 853;
          tls_auth_name = "dns.google";
          tls_pubkey_pinset = [
            { digest = "sha256";
              value = "CxzDnNYQv9RlubDYchc9oCKvvtNyEIsS4kcG9nSBrxQ="; }
          ]; }
      ];
    };
  };

  # DNS Domain Filtering
  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = true;
    extraConfig = ''
      interface=lo
      bind-interfaces

      ${lib.optionalString stubbyEnabled ''
      no-resolv
      proxy-dnssec
      server=127.0.0.1#153
      ''}

      no-negcache
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
