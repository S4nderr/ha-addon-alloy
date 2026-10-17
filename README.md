# Home Assistant add-on: Grafana Alloy (Logarchief)

Stuurt het volledige systemd-journal van Home Assistant OS (host, Supervisor, Core, elke add-on) naar het **Logarchief** van het homelab (VictoriaLogs achter het loket op CT 101), via de Loki-push-API, met Grafana Alloy.

Fork van [ecohash-co/ha-addon-alloy](https://github.com/ecohash-co/ha-addon-alloy) (MIT). Waarom een fork en niet die repo rechtstreeks staat in ADR 0007 van het Logarchief: code met journal-toegang op de HA-box staat onder eigen beheer, Alloy is gepind op dezelfde versie als de vier andere Alloys in het homelab (v1.18.1), en de pijplijn volgt het eigen schema (`host`/`unit` als stream-velden) in plaats van losse labels.

## Installatie

1. **Instellingen → Add-ons → Add-on winkel → ⋮ (rechtsboven) → Repositories**
2. Plak `https://github.com/S4nderr/ha-addon-alloy` → **Toevoegen** → sluiten
3. Zoek **Grafana Alloy (Logarchief)** in de winkel → **Installeren** (HAOS bouwt het image lokaal; de eerste keer duurt dat enkele minuten)
4. Tab **Configuratie**: `loki_url` staat standaard goed voor dit homelab; `host` = `ha`
5. **Starten**, daarna **Log** controleren: de regel `Alloy-config gegenereerd en gevalideerd` en `Alloy is running`

## Opties

| Optie | Standaard | Betekenis |
|---|---|---|
| `loki_url` | `http://192.168.2.51:9428/insert/loki/api/v1/push` | Loki-push-endpoint van het loket |
| `host` | `ha` | Waarde van het stream-veld `host` |
| `max_age` | `720h` | Hoe ver terug Alloy bij de eerste start leest (30 dagen = de bewaartermijn) |
| `log_level` | `info` | Alloy's eigen logniveau |
| `additional_config` | leeg | Extra Alloy-blokken, letterlijk achter de config geplakt |

## Wat er aankomt

Elke journalregel krijgt `host` en `unit` als stream-velden en `ident`, `priority`, `level` (emerg … debug), `transport`, `pid` als gewone velden. HAOS-eigenheid: Core, Supervisor en add-ons loggen via Docker naar de journal en zouden alle `docker.service` als unit krijgen; daarom wordt de containernaam (`homeassistant`, `hassio_supervisor`, `addon_…`) de unit als die er is.

Zoeken: `host:ha _time:24h | stats by (unit) count()` op http://192.168.2.51:9428/select/vmui/.

## Onderhoud

- **Alloy-versie**: `ALLOY_VERSION` in `alloy/Dockerfile`, tegelijk met de andere Alloys in het homelab; `version` in `alloy/config.yaml` ophogen, regel in `alloy/CHANGELOG.md`. HA toont dan een update.
- **Upstream volgen**: `git fetch upstream && git log upstream/main` en handmatig overnemen wat nuttig is; de pijplijn hier is bewust anders.
- **Debug-UI**: poort 12345 staat standaard dicht; in de add-on-configuratie onder *Netwerk* tijdelijk openzetten als het nodig is.
