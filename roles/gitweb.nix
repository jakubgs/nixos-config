{ ... }:

{
  # Hosting
  services.nginx = {
    enable = true;
    gitweb.enable = true;
  };

  # Service
  services.gitweb = {
    projectroot = "/git";
    gitwebTheme = true;
  };
}
