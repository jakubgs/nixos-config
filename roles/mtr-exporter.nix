{ pkgs, channels, fetchFromGitHub, ... }:

{
  # Use new service definition
  disabledModules = [ "services/networking/mtr-exporter.nix" ];
  imports = [ "${channels.unstable}/nixos/modules/services/networking/mtr-exporter.nix" ];

  # Firewall
  networking.firewall.interfaces."zt*".allowedTCPPorts = [ 8080 ];

  services.mtr-exporter = {
    enable = true;
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
      version = "0.4.0-rc.0";
      vendorHash = null;
      src = pkgs.fetchFromGitHub {
        owner = "mgumz";
        repo = "mtr-exporter";
        rev = "9cf7a317c7b34fdc20aef1fc8361dd4fab1a43f0";
        hash = "sha256-Tm6elJkcxh3xM4x2q63wKWrpilK7WEdto7emYNToka0=";
      };
    });
  };
}
