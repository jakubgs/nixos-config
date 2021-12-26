{ lib, secret, ... }:

{
  networking.wireless = {
    enable = true;
    interfaces = [ "wlan0" ];
    networks = let
      # Order matters, last has highest priority.
      names = [ "MAGI" "MAGI 5Ghz" "MAGI v2" ];
    in lib.listToAttrs (lib.imap0 (idx: name: {
      inherit name;
      value = {
        psk = secret "service/wifi/magi/pass";
        priority = idx;
      };
    }) names);
  };
}
