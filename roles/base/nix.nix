{ pkgs, ... }:

{
  nix.package = pkgs.nixVersions.nix_2_28;
  nix.settings = {
    "download-buffer-size" = "268435456";
    "extra-experimental-features" = "flakes nix-command";
    "commit-lockfile-summary" = true;
    "debugger-on-trace" = true;
    "warn-dirty" = false;
    "substituters" = [
      "https://cache.nixos.org/"
      "http://bardiel.magi.vpn:5000/"
    ];
    "trusted-public-keys" = [
      "nix.magi.vpn:Q00cvekd+F+fSujdWFHEWwbkCAozwdaOve6pK/P3aFA="
    ];
  };

  # Lower priority of builds to not Disturb other processes.
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedPriority = 7;

  # Nix Auto Garbage Collect.
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 15";
  };

  # Nix output formatter
  environment.systemPackages = with pkgs; [
    nix-output-monitor
  ];

}
