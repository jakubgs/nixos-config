{ pkgs, ... }:

/* Details: https://nixos.wiki/wiki/Yubikey */
{
  imports = [
    ./security.nix
  ];

  /* Required tools and libraries. */
  environment.systemPackages = with pkgs; [
    ccid opensc pcsctools
  ];

  /* Required udev rules for YubiKey usage */
  services.udev.packages = with pkgs; [
    yubikey-personalization
    libu2f-host
  ];

  /* Necessary for GPG Agent. */
  services.pcscd.enable = true;
}
