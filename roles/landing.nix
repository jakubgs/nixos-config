{ ... }:

{
  imports = [
    ../services/landing.nix
  ];

  services.landing = {
    enable = true;
    machines = [ "arael" "leliel" "caspair" "zeruel" "melchior" ];
  };
}
