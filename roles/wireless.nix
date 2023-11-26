{ lib, secret, ... }:

{
  age.secrets."wifi/magi" = {
    file = ../secrets/wifi.age;
  };

  networking.wireless = {
    enable = true;
    interfaces = [ "wlan0" ];
    environmentFile = secret "services/wifi";
    networks = {
      "MAGI"        = { psk = "@MAGI@"; };
      "MAGI Mobile" = { psk = "@MAGI_Mobile@"; };
    };
  };
}
