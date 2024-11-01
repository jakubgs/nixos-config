{ pkgs, lib, ... }:

{
  # Default fonts are too small.
  console = {
    # Use xserver keyboard settings.
    useXkbConfig = true;
    # Configure font early during boot.
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";
    packages = with pkgs; [ terminus_font ];
  };
}
