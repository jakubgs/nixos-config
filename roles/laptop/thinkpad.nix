{ ... }:

{
  # Fix brightness keys on Thinkpad T480s and others.
  boot.kernelParams = [ "acpi_osi=" ];

  # TLP power management daemon
  services.tlp = {
    enable = true;
    settings = {
      # Options: performance, powersave, schedutil, ondemand, conservative, userspace
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      # Options: performance, balance_performance, balance_power, power
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

      # Options: performance, balanced, low-power
      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      START_CHARGE_THRESH_BAT0 = 75;
    };
  };

  services.power-profiles-daemon.enable = false;
}
