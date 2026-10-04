# meteo-exporter

Small Prometheus exporter for Weather Underground-compatible weather station updates.

Written with Bresser Wifi WSC 5IN1 custom endpoint functionality in mind.

## Usage

```sh
python3 meteo_exporter.py --port 9109 --password-file /run/secrets/meteo-exporter-password
```
Send station updates to the path used by the station:
```text
GET /weatherstation/updateweatherstation.php?ID=PWS-E5FE9C&PASSWORD=change-me&dateutc=now&baromin=29.71&tempf=62.4&dewptf=54.3&humidity=75&windspeedmph=3.5&windgustmph=3.5&winddir=294&rainin=0.0&dailyrainin=0.0&indoortempf=71.7&indoorhumidity=62&softwaretype=vws%20versionxx&action=updateraw&realtime=1&rtfreq2.5
```
Prometheus scrapes `http://localhost:9109/metrics`. Exported metrics use `meteo_` prefix and `station_id` label. Temperature and humidity use `location="indoor"` or `location="outdoor"`. Imperial input values convert to explicit SI-based units where applicable. Update requests without matching `PASSWORD` receive HTTP 403. Other unsupported query fields are discarded.
