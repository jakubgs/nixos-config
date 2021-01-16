{ config, ... }:

{
  imports = [ ../services/gossa.nix ];

  services.gossa = {
    enable = true;
    verbose = true;
    dataDir = "/mnt/photos";
    urlPrefix = "/gossa/";
  };

  services.landing = {
    proxyServices = [{
      name = "/gossa/";
      title = "Gossa";
      value = {
        proxyPass =
          "http://localhost:${toString config.services.gossa.port}/gossa/";
      };
    }];
  };
}
