{ pkgs, config, channels, fetchFromGitHub, ... }:

{
  # Firewall
  networking.firewall.interfaces."zt*".allowedTCPPorts = [
    config.services.mtr-exporter.port
  ];

  services.mtr-exporter = {
    enable = true;
    port = 9001;
    address = "0.0.0.0";
    jobs = [
      { name = "google-icmp";        address = "google.com";                  }
      { name = "google-tcp-443";     address = "google.com";      flags = ["--tcp" "--port=443"]; }
      { name = "github-icmp";        address = "github.com";                  }
      { name = "github-tcp-443";     address = "github.com";      flags = ["--tcp" "--port=443"]; }
      { name = "cloudflare-icmp";    address = "one.one.one.one";             }
      { name = "cloudflare-tcp-443"; address = "one.one.one.one"; flags = ["--tcp" "--port=443"]; }
    ];
  };
}
