{ pkgs, ... }:

let
  clipmenu = pkgs.writeShellScriptBin "clipmenu" ''
    wlcopy() { ${pkgs.wl-clipboard}/bin/wl-copy --trim-newline $@; }
    selection="$(${pkgs.cliphist}/bin/cliphist list | ${pkgs.rofi}/bin/rofi -dmenu -p clip)" || exit 0
    [ -n "$selection" ] || exit 0
    printf '%s' "$selection" \
      | ${pkgs.cliphist}/bin/cliphist decode \
      | ${pkgs.coreutils}/bin/tee >(wlcopy) >(wlcopy --primary) \
      >/dev/null
  '';
in {
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
