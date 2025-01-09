{ pkgs, ... }:

{
  nix.package = pkgs.nixVersions.nix_2_25;
  nix.extraOptions = ''
    extra-experimental-features = flakes nix-command
    debugger-on-trace = true
  '';

  # Lower priority of builds to not Disturb other processes.
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedPriority = 7;

  # Nix Auto Garbage Collect.
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 15";
  };
}
