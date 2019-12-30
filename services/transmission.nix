# This is a small override to control config location.

{ config, lib, pkgs, ... }:

let
  cfg = config.services.transmission;
  homeDir = cfg.home;
  downloadDir = "${homeDir}/Downloads";
  incompleteDir = "${homeDir}/.incomplete";

  settingsDir = "${homeDir}/.transmission-daemon";
  settingsFile = pkgs.writeText "settings.json" (builtins.toJSON fullSettings);

  # for users in group "transmission" to have access to torrents
  fullSettings = { umask = 2; download-dir = downloadDir; incomplete-dir = incompleteDir; } // cfg.settings;

  # Directories transmission expects to exist and be ug+rwx.
  directoriesToManage = [ homeDir settingsDir fullSettings.download-dir fullSettings.incomplete-dir ];
  preStart = pkgs.writeScript "transmission-pre-start" ''
    #!${pkgs.runtimeShell}
    set -ex
    for DIR in ${lib.escapeShellArgs directoriesToManage}; do
      mkdir -p "$DIR"
      chmod 770 "$DIR"
    done
    cp -f ${settingsFile} ${settingsDir}/settings.json
  '';
in
{
  systemd.services.transmission.serviceConfig.ExecStartPre = lib.mkForce preStart;
  systemd.services.transmission.serviceConfig.ExecStart = lib.mkForce
    "${pkgs.transmission}/bin/transmission-daemon -f --port ${toString config.services.transmission.port} --config-dir ${settingsDir }";
}
