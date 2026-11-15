{ pkgs, ... }:

{
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # For ASUS USB adapter
  hardware.firmware = [ pkgs.broadcom-bt-firmware ];

  # Bluetooth audio
  services.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
      # dual = Classic + BLE (def); bredr = Classic only; le = BLE only.
      # Force Classic to avoid JBL A2DP connection issues.
      ControllerMode = "bredr";
    };
  };
}
