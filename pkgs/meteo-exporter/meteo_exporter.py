#!/usr/bin/env python3
"""Prometheus exporter for Weather Underground-compatible weather stations."""

from __future__ import annotations

import argparse
import logging
import math
import secrets
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from typing import Callable, Mapping
from urllib.parse import parse_qs, urlsplit

logging.basicConfig(level=logging.INFO, format='[%(levelname)s] %(message)s')
LOG = logging.getLogger(__name__)



def _fahrenheit_to_celsius(value: float) -> float:
    return (value - 32.0) * 5.0 / 9.0


def _inches_to_meters(value: float) -> float:
    return value * 0.0254


def _inches_per_hour_to_meters_per_second(value: float) -> float:
    return value * 0.0254 / 3600.0


def _miles_per_hour_to_meters_per_second(value: float) -> float:
    return value * 1609.344 / 3600.0


def _inches_hg_to_pascals(value: float) -> float:
    return value * 3386.389


def _percent_to_ratio(value: float) -> float:
    return value / 100.0


MetricConverter = Callable[[float], float]
MetricDefinition = tuple[str, MetricConverter, str | None]


# Input field: (Prometheus metric suffix, conversion, optional location label).
METRICS: Mapping[str, MetricDefinition] = {
    "indoorhumidity": ("indoor",  "relative_humidity_ratio",           _percent_to_ratio),
    "indoortempf":    ("indoor",  "temperature_celsius",               _fahrenheit_to_celsius),
    "baromin":        ("outdoor", "air_pressure_pascals",              _inches_hg_to_pascals),
    "dailyrainin":    ("outdoor", "rain_accumulated_meters",           _inches_to_meters),
    "dewptf":         ("outdoor", "dew_point_temperature_celsius",     _fahrenheit_to_celsius),
    "humidity":       ("outdoor", "relative_humidity_ratio",           _percent_to_ratio),
    "rainin":         ("outdoor", "rain_rate_meters_per_second",       _inches_per_hour_to_meters_per_second),
    "tempf":          ("outdoor", "temperature_celsius",               _fahrenheit_to_celsius),
    "winddir":        ("outdoor", "wind_direction_degrees",            float),
    "windgustmph":    ("outdoor", "wind_gust_speed_meters_per_second", _miles_per_hour_to_meters_per_second),
    "windspeedmph":   ("outdoor", "wind_speed_meters_per_second",      _miles_per_hour_to_meters_per_second),
}


class WeatherMetrics:
    """Thread-safe latest-value store keyed by weather station ID."""

    def __init__(self) -> None:
        self._values: dict[str, dict[tuple[str, str | None], float]] = {}
        self._lock = threading.Lock()

    def update(self, query: Mapping[str, list[str]]) -> int:
        station_ids = query.get("ID", [])
        if not station_ids or not station_ids[0].strip():
            raise ValueError("missing ID")
        station_id = station_ids[0].strip()
        values: dict[tuple[str, str | None], float] = {}
        for input_name, (location, metric_name, converter) in METRICS.items():
            raw_values = query.get(input_name)
            if not raw_values or raw_values[0] == "":
                continue
            try:
                value = converter(float(raw_values[0]))
            except (TypeError, ValueError, OverflowError) as error:
                raise ValueError(f"invalid {input_name}") from error
            if not math.isfinite(value):
                raise ValueError(f"invalid {input_name}")
            values[(metric_name, location)] = value
        if not values:
            raise ValueError("request contains no supported metrics")
        with self._lock:
            self._values[station_id] = values
        return len(values)

    def exposition(self) -> str:
        with self._lock:
            snapshot = {station: dict(values) for station, values in self._values.items()}
        samples_by_metric: dict[str, list[tuple[str, str | None, float]]] = {}
        # Group samples once instead of scanning every station for each metric.
        for station_id, values in snapshot.items():
            for (name, location), value in values.items():
                samples_by_metric.setdefault(name, []).append((station_id, location, value))

        lines: list[str] = []
        # Sorting keeps exposition stable regardless of update order.
        for name in sorted(samples_by_metric):
            lines.append(f"# HELP meteo_{name} Latest weather station {name.replace('_', ' ')}.")
            lines.append(f"# TYPE meteo_{name} gauge")
            samples = sorted(
                samples_by_metric[name],
                key=lambda sample: (sample[0], sample[1] or ""),
            )
            for station_id, location, value in samples:
                labels = f'station_id="{_escape_label(station_id)}"'
                if location is not None:
                    labels += f',location="{location}"'
                lines.append(f"meteo_{name}{{{labels}}} {value:.15g}")
        return "\n".join(lines) + ("\n" if lines else "")


def _escape_label(value: str) -> str:
    return value.replace("\\", "\\\\").replace("\n", "\\n").replace('"', '\\"')


def _has_valid_password(query: Mapping[str, list[str]], password: str) -> bool:
    supplied_password = query.get("PASSWORD", [""])[0]
    return secrets.compare_digest(supplied_password, password)


def _read_password_file(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8").rstrip("\r\n")
    except (OSError, UnicodeError) as error:
        raise ValueError(f"cannot read password file: {path}") from error


class MetricsHandler(BaseHTTPRequestHandler):
    metrics = WeatherMetrics()
    password = ""

    def do_GET(self) -> None:
        parsed = urlsplit(self.path)
        if parsed.path == "/metrics":
            body = self.metrics.exposition().encode()
            self.send_response(200)
            self.send_header("Content-Type", "text/plain; version=0.0.4; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        if parsed.path == "/weatherstation/updateweatherstation.php":
            self._update(parsed.query)
            return
        self.send_error(404)

    def _update(self, query_string: str) -> None:
        query = parse_qs(query_string, keep_blank_values=True)
        client_ip = self.headers.get("X-Real-IP", self.client_address[0])
        if not _has_valid_password(query, self.password):
            LOG.warning("Rejected invalid password from %s", client_ip)
            self.send_error(403, "invalid password")
            return
        try:
            self.metrics.update(query)
        except ValueError as error:
            LOG.warning("Rejected malformed update from %s: %s", client_ip, error)
            self.send_error(400, str(error))
            return
        self.send_response(200)
        self.send_header("Content-Length", "0")
        self.end_headers()

    def log_message(self, format: str, *args: object) -> None:
        return


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--listen-address", default="0.0.0.0")
    parser.add_argument("--port", default=9109, type=int)
    parser.add_argument("--password-file", required=True, type=Path, help="File containing station update password")
    args = parser.parse_args()

    try:
        MetricsHandler.password = _read_password_file(args.password_file)
    except ValueError as error:
        parser.error(str(error))

    server = ThreadingHTTPServer((args.listen_address, args.port), MetricsHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
