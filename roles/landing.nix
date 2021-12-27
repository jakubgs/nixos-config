{ ... }:

{
  imports = [
    ../services/landing.nix
  ];

  services.landing.enable = true;
}
