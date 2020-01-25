{ ... }:

{
  # Increase SSH security
  services.openssh = {
    enable = true;
    openFirewall = true;
    passwordAuthentication = false;
    permitRootLogin = "no";
  };
  # Enable GnuPG agent for keys
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  # Use PAM with SSH auth
  security.pam.enableSSHAgentAuth = true;
}
