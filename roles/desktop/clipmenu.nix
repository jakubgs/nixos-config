{ pkgs, ... }:

let
  clipmenu = pkgs.writeShellScriptBin "clipmenu" ''
    selection="$(${pkgs.cliphist}/bin/cliphist list | ${pkgs.rofi}/bin/rofi -dmenu -p clip)" || exit 0
    [ -n "$selection" ] || exit 0
    printf '%s' "$selection" | ${pkgs.cliphist}/bin/cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy
  '';
in

{
  environment.systemPackages = with pkgs; [
    cliphist
    clipmenu
    wl-clipboard
  ];

  systemd.user.services.cliphist = {
    description = "Wayland clipboard history";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    serviceConfig = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "on-failure";
    };
  };
}
