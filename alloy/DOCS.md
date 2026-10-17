# Grafana Alloy (Logarchief)

Leest het systemd-journal van Home Assistant OS en stuurt elke regel naar het Logarchief (VictoriaLogs achter het loket op 192.168.2.51:9428) via de Loki-push-API.

## Configuratie

- **loki_url** (verplicht): het push-endpoint. Standaard `http://192.168.2.51:9428/insert/loki/api/v1/push`. Het loket laat alleen het adres van de HA-box (192.168.2.49) toe.
- **host**: waarde van het stream-veld `host` (standaard `ha`). Alleen letters, cijfers, `-` en `_`.
- **max_age**: hoe ver terug de eerste lezing gaat (standaard `720h`). Daarna leest Alloy verder vanaf zijn cursor in `/data/alloy`.
- **log_level**: `debug`, `info`, `warn` of `error`.
- **additional_config**: extra Alloy-blokken, letterlijk achter de gegenereerde config geplakt. Een syntaxfout laat de add-on niet starten (de config wordt bij elke start gevalideerd).

## Velden

| Veld | Bron | Rol |
|---|---|---|
| `host` | optie `host` | stream-veld |
| `unit` | `_SYSTEMD_UNIT`, maar `CONTAINER_NAME` als die er is; `session-N.scope` → `session.scope`, `user@N.service` → `user.service`; zonder unit: de identifier | stream-veld |
| `ident` | `SYSLOG_IDENTIFIER` | veld |
| `priority` / `level` | `PRIORITY` (0–7) en de naam ervan | veld |
| `transport` | `_TRANSPORT` (kernel, journal, stdout, syslog) | veld |
| `pid` | `_PID` | veld |

## Problemen

- **Niets in het archief**: controleer in het add-on-log of `Alloy is running` staat en of er `level=error` regels zijn met `403` (loket laat dit adres niet toe) of `connection refused` (loket niet bereikbaar).
- **Add-on start niet**: het log toont de validatiefout; meestal `additional_config`.
- **"timestamp too old"** vlak na de eerste start is normaal: regels ouder dan de bewaartermijn worden geweigerd.
- **Debug-UI**: poort 12345 in de app-configuratie (Instellingen → Apps) onder *Netwerk* openzetten, dan `http://192.168.2.49:12345`. Daarna weer dichtzetten.

## Bron

Fork van [ecohash-co/ha-addon-alloy](https://github.com/ecohash-co/ha-addon-alloy). Beheer: https://github.com/S4nderr/ha-addon-alloy
