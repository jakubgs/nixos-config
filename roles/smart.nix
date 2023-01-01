{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    smartmontools
  ];

  # SMART drive monitoring
  services.smartd = {
    enable = true;
    autodetect = true;
  };
}
