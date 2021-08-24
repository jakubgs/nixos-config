{ pkgs, ... }:

{
  # Packages required for work
  users.users.jakubgs.packages = with pkgs; [
    ledger-live-desktop
  ];

  # Enable udev rules for Ledger
  hardware.ledger.enable = true;

  # Fix permissions
  services.udev.extraRules = '''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0001|1011|1015", GROUP="adm"
  '';
}
