{ pkgs, channels, ... }:

let
  somewm = channels.somewm.packages.${pkgs.stdenv.hostPlatform.system}.default;
  somewmStartup = pkgs.writeShellScript "somewm-startup" ''
    ${pkgs.foot}/bin/foot --server &
    ${pkgs.networkmanagerapplet}/bin/nm-applet --indicator &
    ${pkgs.blueman}/bin/blueman-applet &
    ${pkgs.swaybg}/bin/swaybg -i ${../../files/wallpapers/default.jpg} -m fill &
    # WARNING: This needs to finish so it should not run in background.
    ${pkgs.uwsm}/bin/uwsm finalize
  '';
    #GDK_BACKEND=x11 ${pkgs.pasystray}/bin/pasystray &
    #${pkgs.swayidle}/bin/swayidle -w \
    #  timeout 40 '${pkgs.libnotify}/bin/notify-send -t 10000 "Locking in 20 seconds..."' \
    #  timeout 60 '${pkgs.systemd}/bin/systemctl start physlock' \
    #  before-sleep '${pkgs.systemd}/bin/systemctl start physlock' &
  somewmUwsm = pkgs.writeShellScriptBin "somewm-uwsm" ''
    exec ${somewm}/bin/somewm -s ${somewmStartup}
  '';
in {
  environment.systemPackages = with pkgs; [
    grim slurp swappy foot somewm somewmUwsm swayidle swaylock pwvucontrol
    wl-clipboard wl-gammactl wlr-randr wdisplays nwg-displays wayland xwayland xdg-utils
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_CURRENT_DESKTOP = "somewm";
  };

  services.greetd = {
    enable = true;
    #services.greetd.settings.terminal.vt = 1;
    settings.default_session.command = ''
      ${pkgs.tuigreet}/bin/tuigreet --time --sessions /run/current-system/sw/share/wayland-sessions --remember --remember-session
    '';
  };

  programs.uwsm = {
    enable = true;
    waylandCompositors.somewm = {
      prettyName = "somewm";
      comment = "somewm Wayland compositor managed by UWSM";
      binPath = "${somewmUwsm}/bin/somewm-uwsm";
    };
  };

  services.dbus.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    config.common.default = [ "wlr" "gtk" ];
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
