{ pkgs, ... }:

{
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "caspair.magi.vpn";
      systems = ["x86_64-linux" "aarch64-linux"];
      sshKey = "/home/sochan/.ssh/builder/id_rsa";
      sshUser = "builder";
      maxJobs = 1;
      speedFactor = 2;
      supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
    }
  ];

  # optional, useful when the builder has a faster internet connection than yours
  #nix.extraOptions = ''
  #  builders-use-substitutes = true
  #'';
}
