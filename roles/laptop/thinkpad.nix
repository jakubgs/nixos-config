{ ... }:

{
  # Fix brightness keys on Thinkpad T480s.
  boot.kernelParams = [ "acpi_osi=" ];

  # TLP power management daemon
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      START_CHARGE_THRESH_BAT0 = 75;
    };
  };
}
