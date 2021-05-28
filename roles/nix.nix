{ ... }:

{
  # Lower priority of builds to not Disturb other processes
  nix.daemonNiceLevel = 19;
  nix.daemonIONiceLevel = 7;

  # Nix Auto Garbage Collect
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 15";
  };
}
