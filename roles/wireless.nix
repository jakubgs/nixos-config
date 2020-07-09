{ config, pkgs, lib, ... }:
let
  secrets = import ../secrets.nix;
in {
  networking.wireless = {
    enable = true;
    interfaces = [ "wlan0" ];
    networks = {
      "MAGI" = { psk = secrets.wifiMagiPassword; };
      "MAGI 5Ghz" = { psk = secrets.wifiMagiPassword; };
    };
  };
}
