{ pkgs, ... }:

{
  imports = [
    ./trackpoint.nix
  ];

  # allow brightness control by video group
  hardware.acpilight.enable = true;

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
