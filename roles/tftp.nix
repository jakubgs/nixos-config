{ ... }:

{
  services.atftpd = {
    enable = true;
    root = "/tmp/atftp";
    extraOptions = ["--port=69" "--verbose=7"];
  };

  # Firewall
  networking.firewall.allowedTCPPorts = [ 69 ];
  networking.firewall.allowedUDPPorts = [ 69 ];
}
