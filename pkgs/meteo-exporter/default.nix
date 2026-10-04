{
  lib,
  python3Packages
}:

python3Packages.buildPythonApplication {
  pname = "meteo-exporter";
  version = "0.1.0";

  src = ./.;
  pyproject = true;

  nativeBuildInputs = [
    python3Packages.setuptools
  ];

  checkPhase = ''
    python -m unittest discover -v
  '';

  meta = {
    description = "Prometheus exporter for Weather Underground-compatible weather stations";
    mainProgram = "meteo-exporter";
    platforms = lib.platforms.unix;
  };
}
