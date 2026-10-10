# meteo-dashboard

Static mobile-first weather dashboard for `meteo-exporter` metrics.

Prometheus stores history; exporter itself exposes latest values only.

```sh
meteo-dashboard --station PWS-E5FE9C --output weather.html
```

Prometheus URL defaults to `http://localhost:9090`.

Generator fetches and embeds 24-hour, 7-day, and 30-day ranges. Matplotlib produces inline SVG charts. Generated page uses tiny inline JavaScript for range switching and no external assets. `weather_dashboard.html` is source template for page structure and CSS.
