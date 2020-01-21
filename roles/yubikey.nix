{ pkgs, ... }:

/* Details: https://nixos.wiki/wiki/Yubikey */
{
  /* Required udev rules for YubiKey usage */
  services.udev.packages = with pkgs; [
    yubikey-personalization
    libu2f-host
  ];

  services.pcscd.enable = true;
}
