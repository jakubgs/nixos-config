{ pkgs, ... }:

{
  fonts = {
    fontconfig = {
      cache32Bit = true;
      allowBitmaps = true;
      useEmbeddedBitmaps = true;
      defaultFonts.monospace = [ "Inconsolata" ];
    };

    packages = with pkgs; [
      inconsolata
      terminus_font
      corefonts
      fira-code
      dejavu_fonts
      ubuntu-classic
    ];
  };
}
