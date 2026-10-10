{ lib, python3Packages }:

python3Packages.buildPythonApplication {
  pname = "meteo-dashboard";
  version = "0.1.0";

  src = ./.;
  format = "other";

  propagatedBuildInputs = [
    python3Packages.matplotlib
  ];

  installPhase = ''
    install -Dm755 weather_dashboard.py $out/bin/meteo-dashboard
    install -Dm644 weather_dashboard.html $out/bin/weather_dashboard.html
  '';

  meta = {
    description = "Static SVG weather dashboard generated from Prometheus data";
    mainProgram = "meteo-dashboard";
    platforms = lib.platforms.unix;
  };
}
