{ lib, ... }:

{
  # Reduce timeouts for glibc/NSS resolving.
  networking.resolvconf.extraOptions = ["timeout:1" "attempts:1"];

  # Make /etc/hosts first apps using glibc/NSS resolution.
  system.nssDatabases.hosts = lib.mkForce [
    "files" "mymachines" "myhostname" "resolve [!UNAVAIL=return]" "dns"
  ];
}
