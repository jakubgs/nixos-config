{ ... }:

{
  imports = [
    ../services/landing.nix
  ];

  services.landing = {
    enable = true;
    machines = [ "arael" "bardiel" "leliel" "caspair" "zeruel" "melchior" ];
  };
}
