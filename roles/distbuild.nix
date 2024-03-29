{ ... }:

{
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "bardiel.magi.vpn";
      systems = ["x86_64-linux" "aarch64-linux"];
      sshKey = "/root/.ssh/nixos/builder/id_rsa";
      sshUser = "builder";
      supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
      mandatoryFeatures = [ ];
      speedFactor = 1;
      maxJobs = 1;
    }
    {
      hostName = "caspair.magi.vpn";
      systems = ["x86_64-linux" "aarch64-linux"];
      sshKey = "/root/.ssh/nixos/builder/id_rsa";
      sshUser = "builder";
      supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
      mandatoryFeatures = [ ];
      speedFactor = 1;
      maxJobs = 1;
    }
  ];

  # optional, useful when the builder has a faster internet connection than yours
  #nix.extraOptions = ''
  #  builders-use-substitutes = true
  #'';
}
