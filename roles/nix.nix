{ pkgs, ... }:

{
  # Upgrade from 2.3.16.
  #nix.package = pkgs.nix_2_4;

  # Lower priority of builds to not Disturb other processes.
  nix.daemonCPUSchedPolicy = "idle";
  nix.daemonIOSchedPriority = 7;

  # Nix Auto Garbage Collect.
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 15";
  };
}
