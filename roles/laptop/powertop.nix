{ pkgs, ... }:

{
  # Power auto tuning on startup
  powerManagement.powertop.enable = true;

  environment.systemPackages = [ pkgs.powertop ];

  # Do not put HID devices to sleep
  services.udev.extraRules = ''
    # Disable USB autosuspend for all HID devices
    ACTION=="add", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="03", TEST=="power/control", ATTR{power/control}="on"
  '';
}
