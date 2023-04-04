{ pkgs ? import <nixpkgs-unstable> { } }:

# Necessary to fix subscriptions not updating:
# https://github.com/iv-org/invidious/issues/3717
# https://github.com/iv-org/invidious/pull/3718
pkgs.invidious.overrideAttrs (old: {
  version = "unstable-2023-04-01";

  src = pkgs.fetchFromGitHub {
    owner = "iv-org";
    repo = old.pname;
    fetchSubmodules = true;
    rev = "8db2a93827a4e27a55a9095be15083ea68cdd571";
    sha256 = "sha256-81V8XMbxV05wMCTDh0SGcZPdBmJj1oJYobpaOyDBmME=";
  };
})
