{ pkgs, ... }:

{
  # allow brightness control by video group
  hardware.acpilight.enable = true;

  # TLP power management daemon
  services.tlp = {
    enable = true;
    extraConfig = ''
      CPU_SCALING_GOVERNOR_ON_AC=performance
      CPU_SCALING_GOVERNOR_ON_BAT=powersave
    '';
  };

  environment.systemPackages = with pkgs; [
    xorg.xbacklight
  ];
}
