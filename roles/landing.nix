{ secret, ... }:

{
  imports = [
    ../services/landing.nix
  ];

  age.secrets."service/landing/htpasswd" = {
    file = ../secrets/service/grafana/pass.age;
    group = "nginx";
  };

  services.landing = {
    enable = true;
    htpasswdFile = secret "service/landing/htpasswd";
  };
}
