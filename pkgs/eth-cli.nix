{ pkgs ? import <nixpkgs> { } }:

pkgs.yarn2nix-moretea.mkYarnPackage rec {
  pname = "eth-cli";
  version = "2.0.2";

  nodejs = pkgs.nodejs_22;

  src = pkgs.fetchFromGitHub {
    owner = "protofire";
    repo = pname;
    rev = "32a355b5beb250f62800745d65f26d577d87c8ef";
    hash = "sha256-X9ugmJTnIE+04ZiV8OC3Ms+/KJwqPQ1L1Zv7JoH6ZZQ=";
  };

  doCheck = false;

  meta = with pkgs.lib; {
    description = "CLI swiss army knife for Ethereum developers";
    homepage = "https://github.com/protofire/eth-cli";
    license = licenses.mit;
    maintainers = with maintainers; [ jakubgs ];
  };
}
