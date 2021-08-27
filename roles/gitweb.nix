{ config, ... }:

{
  # Hosting
  services.nginx = {
    enable = true;
    gitweb = {
      enable = true;
      location = "/gitweb";
      virtualHost = "${config.networking.hostName}.${config.networking.domain}";
    };
  };

  # Service
  services.gitweb = {
    projectroot = "/mnt/git";
    gitwebTheme = true;
  };

  services.landing = {
    proxyServices = [{
      name = "/gitweb/";
      title = "WebGit";
      value = {
        proxyPass = "http://localhost:80/gitweb/";
        extraConfig = ''
          proxy_set_header Host default;
        '';
      };
    }];
  };
}
