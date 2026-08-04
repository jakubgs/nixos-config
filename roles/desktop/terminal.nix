{ ... }:

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Inconsolata:size=20";
        selection-target = "both";
        # Fix for transparrent bottom and right edge.
        resize-by-cells = "no";
      };
      scrollback.lines = 100000;
      colors-dark = {
        alpha = "1.0";
        background = "242424";
        foreground = "e9e9e9";
      };
      csd = {
        preferred = "none";
        size = 0;
        "border-width" = 0;
      };
    };
  };
}
