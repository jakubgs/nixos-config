{ pkgs, ... }:

{
  imports = [
    ./trackpoint.nix
    ./thinkpad.nix
    ./powertop.nix
  ];

  # Lid closing behaviors
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "lock";
    extraConfig = "HandlePowerKey=suspend";
  };

  # Allow brightness control by video group.
  hardware.acpilight.enable = true;

  environment.systemPackages = with pkgs; [
    xorg.xbacklight
  ];
}
