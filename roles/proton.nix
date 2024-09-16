{ pkgs, channels, ... }:

{
  imports = [
    ../services/protonmail-bridge.nix
  ];

  # Enable service that bridges SMTP with ProtonMail
  services.protonmail-bridge.enable = true;
}
