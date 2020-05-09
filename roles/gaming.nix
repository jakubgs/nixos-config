{ pkgs, ... }:

{
  # Enable 32bit OpenGL and PulseAudio
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;

  # Packages required for work
  users.users.sochan.packages = with pkgs; [
    steam
    lutris
    wineWowPackages.staging
    winetricks
    xboxdrv
  ];
}
