{ pkgs, lib, ... }:

let
  # Custom Latex distribution
  myTexLive = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-basic latexmk collection-latexextra;
  };
in {
  # Packages required for work
  users.users.sochan.packages = with pkgs; [ pandoc myTexLive ];
}
