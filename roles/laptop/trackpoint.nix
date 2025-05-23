{ ... }:

{
  services.libinput.enable = false;

  services.xserver.synaptics = {
    enable = true;
    # Disable touchpad
    additionalOptions = ''
      Option "TouchpadOff" "1"
    '';
  };

  hardware.trackpoint = {
    enable = true;
    device = "Elan TrackPoint";
  };
}
