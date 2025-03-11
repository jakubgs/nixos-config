{ ... }:

{
  # Set Brave as default browser
  xdg.mime = {
    enable = true;
    defaultApplications = {
      "text/html"                = "brave.desktop";
      "x-scheme-handler/http"    = "brave.desktop";
      "x-scheme-handler/https"   = "brave.desktop";
      "x-scheme-handler/about"   = "brave.desktop";
      "x-scheme-handler/unknown" = "brave.desktop";
    };
  };
}
