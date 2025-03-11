{ pkgs, ... }:

let
  # Custom Latex distribution
  myTexLive = pkgs.texlive.combine {
    inherit (pkgs.texlive)
      scheme-basic latexmk
      collection-latexextra
      collection-xetex;
  };
in {
  # Packages required for work
  users.users.jakubgs.packages = with pkgs; [ pandoc myTexLive ];
}
