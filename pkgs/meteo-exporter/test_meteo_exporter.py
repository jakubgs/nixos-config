import unittest
from pathlib import Path
from tempfile import TemporaryDirectory
from urllib.parse import parse_qs

from meteo_exporter import WeatherMetrics, _has_valid_password, _read_password_file


REQUEST = (
    "ID=EXAMPLE_ID&PASSWORD=secret&dateutc=now&baromin=29.71&tempf=62.4&"
    "dewptf=54.3&humidity=75&windspeedmph=3.5&windgustmph=3.5&winddir=294&"
    "rainin=0.0&dailyrainin=0.0&indoortempf=71.7&indoorhumidity=62"
)


class WeatherMetricsTest(unittest.TestCase):
    def test_reads_password_file_and_strips_trailing_newline(self):
        with TemporaryDirectory() as directory:
            password_file = Path(directory) / "password"
            password_file.write_text("secret\n", encoding="utf-8")

            self.assertEqual(_read_password_file(password_file), "secret")

    def test_converts_and_exports_station_metrics(self):
        metrics = WeatherMetrics()
        metrics.update(parse_qs(REQUEST))
        output = metrics.exposition()
        self.assertIn('meteo_temperature_celsius{station_id="EXAMPLE_ID",location="outdoor"} 16.8888888888889', output)
        self.assertIn('meteo_wind_speed_meters_per_second{station_id="EXAMPLE_ID",location="outdoor"} 1.56464', output)
        self.assertIn('meteo_relative_humidity_ratio{station_id="EXAMPLE_ID",location="outdoor"} 0.75', output)
        self.assertNotIn("PASSWORD", output)

    def test_handler_requires_matching_password(self):
        self.assertTrue(_has_valid_password(parse_qs("PASSWORD=secret"), "secret"))
        self.assertFalse(_has_valid_password(parse_qs("PASSWORD=wrong"), "secret"))
        self.assertFalse(_has_valid_password(parse_qs("ID=station"), "secret"))

    def test_rejects_missing_station_or_metrics(self):
        metrics = WeatherMetrics()
        with self.assertRaises(ValueError):
            metrics.update(parse_qs("tempf=70"))
        with self.assertRaises(ValueError):
            metrics.update(parse_qs("ID=station"))

    def test_updates_station_without_removing_other_stations(self):
        metrics = WeatherMetrics()
        metrics.update(parse_qs("ID=two&tempf=50"))
        metrics.update(parse_qs("ID=one&tempf=32"))
        output = metrics.exposition()
        samples = [
            line for line in output.splitlines()
            if line.startswith("meteo_temperature_celsius{")
        ]
        self.assertEqual(len(samples), 2)
        self.assertIn('station_id="one"', samples[0])
        self.assertIn('station_id="two"', samples[1])


if __name__ == "__main__":
    unittest.main()
