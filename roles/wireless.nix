{ lib, secret, ... }:

{
  age.secrets."service/wifi" = {
    file = ../secrets/service/wifi.age;
  };

  networking.wireless = {
    enable = true;
    interfaces = [ "wlan0" ];
    secretsFile = secret "service/wifi";
    networks = {
      "MAGI"        = { psk = "ext:MAGI"; };
      "MAGI Mobile" = { psk = "ext:MAGI_Mobile"; };
    };
  };
}
