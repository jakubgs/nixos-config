{ pkgs ? import <nixpkgs> { } }:

pkgs.stdenv.mkDerivation rec {
  pname = "ethstaker-deposit-cli";
  version = "1.2.2";
  commit = "b13dcb9";

  src = pkgs.fetchurl {
    url = "https://github.com/ethstaker/ethstaker-deposit-cli/releases/download/v${version}/ethstaker_deposit-cli-${commit}-linux-amd64.tar.gz";
    hash = "sha256-BK8/T9L9zPSuBgq95HY3YioxEU2fLlPmJyKmlKTVsgY=";
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
    homepage = "https://github.com/ethstaker/ethstaker-deposit-cli";
    mainProgram = "deposit";
  };
}
