{ unstable, ... }:

{
  # Packages required for work
  users.users.jakubgs.packages = with unstable; [
    ledger-live-desktop
  ];

  # Enable udev rules for Ledger
  hardware.ledger.enable = true;

  # Fix permissions
  # https://github.com/LedgerHQ/udev-rules/blob/master/20-hw1.rules
  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0001|1011|1015", MODE="0666", GROUP="adm"
  '';
}
