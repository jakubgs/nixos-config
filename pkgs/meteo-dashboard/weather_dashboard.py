#!/usr/bin/env python3
"""Build one mobile-first HTML weather dashboard from Prometheus history."""

from __future__ import annotations

import argparse
import html
import io
import logging
import math
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import Request, urlopen
import json

LOG = logging.getLogger("weather-dashboard")

METRICS = {
    "temperature": ("meteo_temperature_celsius{location=\"outdoor\",station_id=\"{station}\"}", "Outdoor temperature", "°C", "#f97316", 1),
    "indoor_temperature": ("meteo_temperature_celsius{location=\"indoor\",station_id=\"{station}\"}", "Indoor temperature", "°C", "#facc15", 1),
    "humidity": ("meteo_relative_humidity_ratio{location=\"outdoor\",station_id=\"{station}\"}", "Outdoor humidity", "%", "#0ea5e9", 100),
    "indoor_humidity": ("meteo_relative_humidity_ratio{location=\"indoor\",station_id=\"{station}\"}", "Indoor humidity", "%", "#22d3ee", 100),
    "pressure": ("meteo_air_pressure_pascals{station_id=\"{station}\"}", "Pressure", "hPa", "#8b5cf6", 0.01),
    "wind": ("meteo_wind_speed_meters_per_second{station_id=\"{station}\"}", "Wind speed", "m/s", "#14b8a6", 1),
    "gust": ("meteo_wind_gust_speed_meters_per_second{station_id=\"{station}\"}", "Wind gust", "m/s", "#14b8a6", 1),
    "rain_rate": ("meteo_rain_rate_meters_per_second{station_id=\"{station}\"}", "Rain rate", "mm/h", "#2563eb", 3600000),
    "rain_today": ("meteo_rain_accumulated_meters{station_id=\"{station}\"}", "Rain today", "mm", "#2563eb", 1000),
    "dew_point": ("meteo_dew_point_temperature_celsius{station_id=\"{station}\"}", "Dew point", "°C", "#c084fc", 1),
}

CHART_GROUPS = (
    (("temperature", "indoor_temperature"), "Temperature", "°C"),
    (("humidity", "indoor_humidity"), "Humidity", "%"),
    (("pressure",), "Pressure", "hPa"),
    (("wind",), "Wind speed", "m/s"),
    (("rain_rate",), "Rain rate", "mm/h"),
    (("dew_point",), "Dew point", "°C"),
)


def _selector_escape(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')


def _fetch(url: str, query: str, start: float, end: float, step: int) -> list[tuple[float, float]]:
    params = urlencode({"query": query, "start": start, "end": end, "step": step})
    request = Request(f"{url.rstrip('/')}/api/v1/query_range?{params}", headers={"Accept": "application/json"})
    with urlopen(request, timeout=20) as response:
        payload = json.load(response)
    if payload.get("status") != "success":
        raise ValueError(payload.get("error", "Prometheus query failed"))
    result = payload.get("data", {}).get("result", [])
    if not result:
        return []
    points = []
    for timestamp, value in result[0].get("values", []):
        number = float(value)
        if math.isfinite(number):
            points.append((float(timestamp), number))
    return points


def _svg_chart(series: list[tuple[str, list[tuple[float, float]], str]], title: str, unit: str, max_points: int) -> str:
    import matplotlib
    matplotlib.use("Agg")
    import matplotlib.pyplot as plt

    figure, axis = plt.subplots(figsize=(8, 2.25), dpi=110)
    figure.patch.set_alpha(0)
    axis.set_facecolor("#111827")
    all_x = []
    all_y = []
    plotted = []
    for label, points, color in series:
        if len(points) > max_points:
            points = points[::max(1, len(points) // max_points)]
        if points:
            x, y = zip(*points)
            axis.plot(x, y, color=color, linewidth=1.8, label=label, zorder=3)
            all_x.extend(x)
            all_y.extend(y)
            plotted.append((x, y, color))
    if all_y:
        baseline = min(all_y)
        for x, y, color in plotted:
            axis.fill_between(x, y, baseline, color=color, alpha=0.12, zorder=1)
    if all_x:
        axis.set_xlim(min(all_x), max(all_x) or min(all_x) + 1)
    axis.grid(axis="y", color="#334155", linewidth=0.65, alpha=0.7)
    axis.tick_params(colors="#94a3b8", labelsize=8, length=0)
    for spine in axis.spines.values():
        spine.set_visible(False)
    axis.set_title(f"{title} ({unit})", loc="left", color="#e5e7eb", fontsize=10, fontweight="bold", pad=9)
    if len(series) > 1:
        legend = axis.legend(
            loc="lower right",
            bbox_to_anchor=(1, 1.01),
            frameon=False,
            fontsize=8,
            ncol=len(series),
            borderaxespad=0,
        )
        for text in legend.get_texts():
            text.set_color("#cbd5e1")
    date_format = "%H:%M" if max(all_x, default=0) - min(all_x, default=0) <= 36 * 3600 else "%d %b"
    axis.xaxis.set_major_formatter(lambda value, _: datetime.fromtimestamp(value, timezone.utc).strftime(date_format))
    figure.tight_layout(pad=0.8)
    output = io.StringIO()
    figure.savefig(output, format="svg", transparent=True, metadata={"Date": None})
    plt.close(figure)
    svg = output.getvalue()
    svg = svg.replace('<?xml version="1.0" encoding="utf-8" standalone="no"?>', "")
    return svg.replace('<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN"\n"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">', "")


def _value(value: float | None, unit: str) -> str:
    return "--" if value is None else f"{value:.1f} {unit}"


def _charts(data: dict[str, list[tuple[float, float]]], max_points: int) -> str:
    charts = []
    for names, title, unit in CHART_GROUPS:
        series = []
        for name in names:
            _, label, _, color, scale = METRICS[name]
            points = [(timestamp, value * scale) for timestamp, value in data[name]]
            series.append((label.removesuffix(f" {title.lower()}"), points, color))
        if any(points for _, points, _ in series):
            chart = _svg_chart(series, title, unit, max_points)
        else:
            chart = f'<div class="empty">{html.escape(title)}<br><small>No data</small></div>'
        charts.append(f'<section class="panel">{chart}</section>')
    return "".join(charts)


def _page(station: str, end: float, views: dict[str, tuple[float, dict[str, list[tuple[float, float]]]]], max_points: int) -> str:
    cards = []
    for name in ("temperature", "indoor_temperature", "humidity", "pressure", "wind", "rain_rate"):
        _, title, unit, color, scale = METRICS[name]
        points = [(timestamp, value * scale) for timestamp, value in views["24h"][1][name]]
        latest = points[-1][1] if points else None
        cards.append(f'<div class="stat"><span>{html.escape(title)}</span><strong>{html.escape(_value(latest, unit))}</strong></div>')
    generated = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    template = Path(__file__).with_name("weather_dashboard.html").read_text(encoding="utf-8")
    chart_views = "".join(
        f'<div class="view" data-view="{name}"{("" if name == "24h" else " hidden")}>{_charts(data, max_points)}</div>'
        for name, (_, data) in views.items()
    )
    replacements = {
        "{{STATION}}": html.escape(station),
        "{{UPDATED}}": datetime.fromtimestamp(end, timezone.utc).strftime("%Y-%m-%d %H:%M UTC"),
        "{{CARDS}}": "".join(cards),
        "{{CHARTS}}": chart_views,
        "{{GENERATED}}": generated,
    }
    for marker, value in replacements.items():
        template = template.replace(marker, value)
    return template


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--prometheus-url", default="http://localhost:9090", help="Prometheus base URL (default: http://localhost:9090)")
    parser.add_argument("--station", default="PWS-E5FE9C")
    parser.add_argument("--step", type=int, default=300)
    parser.add_argument("--max-points", type=int, default=240)
    parser.add_argument("--output", type=Path, default=Path("weather.html"))
    args = parser.parse_args()
    if args.step <= 0 or args.max_points <= 0:
        parser.error("--step and --max-points must be positive")
    end = time.time()
    try:
        station = _selector_escape(args.station)
        views = {}
        for view, hours, step in (("24h", 24, args.step), ("7d", 24 * 7, max(args.step, 1800)), ("30d", 24 * 30, max(args.step, 3600))):
            start = end - hours * 3600
            data = {name: _fetch(args.prometheus_url, metric[0].replace("{station}", station), start, end, step) for name, metric in METRICS.items()}
            views[view] = (start, data)
        args.output.write_text(_page(args.station, end, views, args.max_points), encoding="utf-8")
    except (OSError, ValueError, TypeError) as error:
        LOG.error("cannot generate dashboard: %s", error)
        return 1
    print(f"wrote {args.output} ({args.output.stat().st_size} bytes)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
