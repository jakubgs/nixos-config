{ secret, ... }:

{
  imports = [
    ../services/landing.nix
  ];

  age.secrets."service/landing/htpasswd" = {
    file = ../secrets/service/landing/htpasswd.age;
    owner = "nginx";
  };

  services.landing = {
    enable = true;
    htpasswdFile = secret "service/landing/htpasswd";
  };
}
