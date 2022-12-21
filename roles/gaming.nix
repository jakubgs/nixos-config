{ pkgs, ... }:

{
  # Enable 32bit OpenGL and PulseAudio
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
  hardware.pulseaudio.support32Bit = true;

  # Gaming mouse configuration
  services.ratbagd.enable = true;

  # Packages required for work
  users.users.jakubgs.packages = with pkgs; [
    steam
    lutris
    corefonts
    vulkan-tools
    # Wine
    wineWowPackages.stableFull
    winetricks
    # Mouse
    piper
    # Games
    #dwarf-fortress-packages.dwarf-fortress-full
  ];
}
