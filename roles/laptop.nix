{ pkgs, ... }:

{
  # allow brightness control by video group
  hardware.acpilight.enable = true;

  environment.systemPackages = with pkgs; [
    xorg.xbacklight
  ];
}
