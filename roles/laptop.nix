{ pkgs, ... }:

{
  imports = [
    ./trackpoint.nix
  ];

  # Fix brightness keys on Thinkpad T480s.
  boot.kernelParams = [ "acpi_osi=" ];

  # Lid closing behaviors
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "lock";
    extraConfig = "HandlePowerKey=suspend";
  };

  # Allow brightness control by video group.
  hardware.acpilight.enable = true;

  # Automatically detect screen layout changes.
  services.autorandr.enable = true;

  # TLP power management daemon
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      START_CHARGE_THRESH_BAT0 = 75;
    };
  };

  environment.systemPackages = with pkgs; [
    xorg.xbacklight
  ];
}
