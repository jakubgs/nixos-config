{ pkgs, ... }:

{
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # For ASUS USB adapter
  hardware.firmware = [ pkgs.broadcom-bt-firmware ];

  # Bluetooth audio
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  hardware.bluetooth.config = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };
}
