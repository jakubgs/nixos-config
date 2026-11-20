{ ... }:

{
  services.netbird = {
    enable = true;

    clients.default = {
      dns-resolver = {
        address = "127.0.0.1";
        port = 5053;
      };

      config = {
        DisableDNS = false;
        ServerSSHAllowed = false;
      };

      environment.NB_DISABLE_SSH_CONFIG = "true";
    };
  };

  services.dnsmasq.settings = {
    server = [
      "/wg.internal/127.0.0.1#5053"
    ];
  };
}
