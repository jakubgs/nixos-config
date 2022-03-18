{ pkgs, ... }:

{
  # Upgrade from 2.3.16.
  nix.package = pkgs.unstable.nixVersions.nix_2_7;
  nix.extraOptions = ''
    extra-experimental-features = flakes nix-command
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
