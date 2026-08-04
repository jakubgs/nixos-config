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

        regular0 = "2e3436";
        regular1 = "cc0000";
        regular2 = "afd700";
        regular3 = "c4a000";
        regular4 = "3465a4";
        regular5 = "75507b";
        regular6 = "7e9fd5";
        regular7 = "d3d7cf";

        bright0 = "555753";
        bright1 = "ef2929";
        bright2 = "afd700";
        bright3 = "fce94f";
        bright4 = "729fcf";
        bright5 = "ad7fa8";
        bright6 = "34e2e2";
        bright7 = "eeeeec";
      };
      csd = {
        preferred = "none";
        size = 0;
        "border-width" = 0;
      };
    };
  };
}
