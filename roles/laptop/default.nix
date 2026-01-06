{ pkgs, ... }:

{
  imports = [
    ./trackpoint.nix
    ./thinkpad.nix
    ./powertop.nix
    ./usbguard.nix
  ];

  # Lid closing behaviors
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "ignore";
    HandlePowerKey = "suspend";
  };

  # Allow brightness control by video group.
  hardware.acpilight.enable = true;

  environment.systemPackages = with pkgs; [
    xorg.xbacklight
  ];
}
