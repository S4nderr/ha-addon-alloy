# Changelog

## 1.1.0 - 2026-10-17 (fork S4nderr)

### Gewijzigd
- Alloy v1.18.1 (was 1.13.1), gelijk aan de andere Alloys in het homelab
- Pijplijn vervangen door het Logarchief-schema: stream-velden `host,unit` (via `VL-Stream-Fields`), velden `ident`, `priority`, `level`, `transport`, `pid`; `VL-Decolorize-Fields: _msg`
- `CONTAINER_NAME` wordt de unit voor containerregels (anders is alles `docker.service`)
- Config uit een sjabloon (`/etc/alloy/config.alloy.tpl`) in plaats van een heredoc; wordt bij elke start gevalideerd
- Nieuwe opties `host` (standaard `ha`) en `max_age` (standaard `720h`); `loki_url` standaard het loket van het homelab
- Debug-poort 12345 standaard niet gepubliceerd; `--disable-reporting`
- Documentatie in het Nederlands

## 1.0.0 - 2026-02-21 (upstream ecohash-co)

### Added
- Initial release
- Grafana Alloy v1.13.1
- Systemd journal log shipping to Loki
- Journal field relabeling (unit, hostname, syslog_identifier, transport, container_name, level)
- Debug UI on port 12345
- Configurable Loki URL, log level, and additional config
- Watchdog health check via Alloy's `/-/ready` endpoint
- Support for amd64 and aarch64 architectures
