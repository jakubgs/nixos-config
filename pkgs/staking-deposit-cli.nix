{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation rec {
  pname = "staking-deposit-cli";
  version = "2.8.0";

  src = pkgs.fetchurl {
    url = "https://github.com/ethereum/staking-deposit-cli/releases/download/v${version}/staking_deposit-cli-948d3fc-linux-amd64.tar.gz";
    hash = "sha256-7wISUqvSWR7201WPsyWLNfR4wgMz8t/0oXzHm1c8OHk=";
  };

  nativeBuildInputs = [ pkgs.autoPatchelfHook ];

  buildInputs = [ pkgs.zlib ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mv ./deposit $out/bin/deposit
    runHook postInstall
  '';

  meta = {
    description = "Secure key generation for deposits";
    homepage = "https://github.com/ethereum/staking-deposit-cli";
    mainProgram = "deposit";
  };
}
