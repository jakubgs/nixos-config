{ config, ... }:

{
  services.ntopng = {
    enable = true;
    http-port = 9094;
    extraConfig = ''
      --disable-login
      --http-prefix=/ntopng
    '';
  };

  services.landing = {
    proxyServices = [{
      name = "/ntopng/";
      title = "ntopng";
      value = {
        proxyPass = "http://localhost:${toString config.services.ntopng.http-port}/";
      };
    }];
  };
}
