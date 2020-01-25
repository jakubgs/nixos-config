{ ... }:

{
  # Security
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  services.openssh.enable = true;
  services.openssh.openFirewall = true;
  services.openssh.passwordAuthentication = false;
  security.pam.enableSSHAgentAuth = true;
}
