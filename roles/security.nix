{ pkgs, ... }:

{
  # Drop packets by default.
  networking.firewall = {
    enable = true;
    extraCommands = ''
      iptables -P INPUT DROP
      iptables -P FORWARD DROP
    '';
  };

  # Increase SSH security.
  services.openssh = {
    enable = true;
    openFirewall = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };

  # Enable GnuPG agent for keys.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    enableBrowserSocket = true;
    pinentryFlavor = "gnome3";
  };

  # Use PAM with SSH auth.
  security.pam.enableSSHAgentAuth = true;
}
