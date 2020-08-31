{ ... }:

{
  services.xserver.libinput.enable = false;

  services.xserver.synaptics = { 
    enable = true;
    # Disable touchpad
    additionalOptions = ''
      Option "TouchpadOff" "1"
    '';
  };
}
