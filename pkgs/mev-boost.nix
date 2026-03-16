{ pkgs ? import <nixpkgs> { } }:

pkgs.buildGo124Module rec {
  pname = "mev-boost";
  version = "1.12";

  src = pkgs.fetchFromGitHub {
    owner = "flashbots";
    repo = "mev-boost";
    rev = "v${version}";
    hash = "sha256-ZGeY3iNsOdAso7aMv0XMm1x2EhR8lz27joGIsz40Ibc=";
  };

  vendorHash = "sha256-dIc0ZHTx+7P621FvfDKlItc/FazUpwxRmDQF2SNVIwA=";

  doCheck = false;

  meta = with pkgs.lib; {
    description = "Ethereum block-building middleware";
    homepage = "https://github.com/flashbots/mev-boost";
    license = licenses.mit;
    mainProgram = "mev-boost";
    maintainers = with maintainers; [ ekimber ];
    platforms = platforms.unix;
  };
}
