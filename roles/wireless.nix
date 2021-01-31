{ config, pkgs, lib, ... }:
let
  secrets = import ../secrets.nix;
in {
  networking.wireless = {
    enable = true;
    interfaces = [ "wlan0" ];
    networks = let
      # Order matters, last has highest priority.
      names = [ "MAGI v2" "MAGI" "MAGI 5Ghz" ];
    in lib.listToAttrs (lib.imap0 (idx: name: {
      inherit name;
      value = {
        psk = secrets.wifiMagiPassword;
        priority = idx;
      };
    }) names);
  };
}
