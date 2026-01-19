{ lib, pkgs, channels, ... }:

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
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = lib.mkForce "no";
    };
  };

  # Enable GnuPG agent for keys.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    enableBrowserSocket = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  # Use PAM with SSH auth.
  security.pam.sshAgentAuth.enable = true;

  # Install Agenix CLI tool.
  environment.systemPackages = with channels.agenix; [
    packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
