{ ... }:

{
  imports = [
    ../services/landing.nix
  ];

  services.landing = {
    enable = true;
    machines = [ "bardiel" "leliel" "caspair" "zeruel" "melchior" ];
  };
}
