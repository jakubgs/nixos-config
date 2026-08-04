{ pkgs, ... }:

{
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # For ASUS USB adapter
  hardware.firmware = [ pkgs.broadcom-bt-firmware ];

  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };
}
