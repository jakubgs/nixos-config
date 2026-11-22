{ lib, pkgs, unstablePkgs, config, ... }:

let
  inherit (lib) concatStringsSep mapAttrsToList optionalAttrs;

  stubbyEnabled = true;

  stubbyExample = pkgs.stubby.passthru.settingsExample;
  blockedHosts = pkgs.callPackage ../../pkgs/blocked-hosts.nix { };

  formatConfig = ip: fqdns:
    concatStringsSep "\n" (map (fqdn: "address=/${fqdn}/${ip}") fqdns);
in {
  # DNS over TLS
  services.stubby = {
    enable = stubbyEnabled;
    logLevel = "info";
    settings = stubbyExample // {
      listen_addresses = [ "127.0.1.153:53" ];
      dnssec = "GETDNS_EXTENSION_TRUE";
      dnssec_trust_anchors = "${pkgs.dns-root-data}/root.key";
      # Validate upstream TLS certificates by hostname.
      tls_authentication = "GETDNS_AUTHENTICATION_REQUIRED";
      round_robin_upstreams = 0;
      upstream_recursive_servers = [
        { tls_auth_name = "dot1.applied-privacy.net"; address_data = "146.255.56.98"; tls_port = 443; }
        { tls_auth_name = "dns.quad9.net";            address_data = "9.9.9.9";       tls_port = 853; }
        { tls_auth_name = "dns.adguard-dns.com";      address_data = "94.140.14.14";  tls_port = 853; }
        { tls_auth_name = "cloudflare-dns.com";       address_data = "1.1.1.1";       tls_port = 853; }
      ];
    };
  };

  # DNS Domain Filtering
  services.dnsmasq = {
    enable = true;
    # FIXME: Remove once stable has 2.93 release.
    package = unstablePkgs.dnsmasq;
    resolveLocalQueries = true;
    settings = {
      log-debug = false;
      log-queries = "only_failed"; # false, true, extra, proto, auth, only_failed
      interface = "lo";
      bind-interfaces = true;
      no-resolv = true;
      cache-size = 10000;
      local-ttl = 300;
      local = "/magi.lan/";
      conf-dir = "/etc/dnsmasq.d/,*.conf";
      addn-hosts = "${blockedHosts}/hosts";
    } // optionalAttrs stubbyEnabled {
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
