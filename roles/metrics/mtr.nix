{ pkgs, config, channels, fetchFromGitHub, ... }:

{
  # Use new service definition
  disabledModules = [ "services/networking/mtr-exporter.nix" ];
  imports = [ "${channels.unstable}/nixos/modules/services/networking/mtr-exporter.nix" ];

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
      { name = "google-tcp-80";      address = "google.com";      flags = ["--tcp" "--port=80"]; }
      { name = "google-tcp-443";     address = "google.com";      flags = ["--tcp" "--port=443"]; }
      { name = "github-icmp";        address = "github.com";                  }
      { name = "github-tcp-80";      address = "github.com";      flags = ["--tcp" "--port=80"]; }
      { name = "github-tcp-443";     address = "github.com";      flags = ["--tcp" "--port=443"]; }
      { name = "cloudflare-icmp";    address = "one.one.one.one";             }
      { name = "cloudflare-tcp-80";  address = "one.one.one.one"; flags = ["--tcp" "--port=80"]; }
      { name = "cloudflare-tcp-443"; address = "one.one.one.one"; flags = ["--tcp" "--port=443"]; }
    ];

    # https://github.com/mgumz/mtr-exporter/pull/13
    # branch: feature/add-labels-first-intermediate
    package = pkgs.unstable.mtr-exporter.overrideAttrs (_: {
      version = "0.5.1";
      vendorHash = null;
      src = pkgs.fetchFromGitHub {
        owner = "mgumz";
        repo = "mtr-exporter";
        rev = "d49969f6ab7d586e966204e7e56a717f0d07b7fb";
        hash = "sha256-+myQg27TGclU+SfU8oO+DvXYqc/8sWE2zRK6fL2DhwM=";
      };
    });
  };
}
