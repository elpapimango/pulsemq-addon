# WispMQ

An MQTT v5.0 / v3.1.1 / v3.1 broker, built directly from the OASIS specs. This
add-on wraps the [official wispmq image](https://github.com/elpapimango/wispmq)
unchanged — see that repo for the full option/environment-variable reference
and protocol details.

## Ports

- `1883/tcp` — MQTT
- `9001/tcp` — Admin HTTP: `/health`, Prometheus `/metrics`, MCP

## Options

| Option | Default | Meaning |
|---|---|---|
| `allow_anonymous` | `true` | Allow clients to connect without credentials |
| `max_connections_per_ip` | `0` | Max new connections per source IP per 10s window; `0` = unlimited |
| `sys_interval` | `10` | `$SYS/broker/...` status refresh interval (s); `0` disables it |
| `ha_discovery` | `true` | Publish Home Assistant MQTT Discovery config + state topics for every broker statistic — Home Assistant's own MQTT integration then auto-creates sensor entities (clients connected, retained messages, publish throughput, ...) with no further setup |
| `ha_discovery_prefix` | `homeassistant` | Must match Home Assistant's own discovery prefix (only change this if you changed it there) |
| `admin_token` | _(unset)_ | Bearer token required on `/metrics` and MCP; leave blank while the admin port is only reachable from inside your network |
| `log_level` | `info` | `trace` / `debug` / `info` / `warn` / `error` |

## Enabling MQTT Discovery in Home Assistant

Home Assistant's built-in **MQTT** integration (Settings → Devices & Services
→ Add Integration → MQTT) needs to be connected to this broker
(`<your-ha-host>:1883`) for the discovered sensors to appear. Discovery is on
by default on the Home Assistant side; this add-on's `ha_discovery: true`
option is the broker-side half of that handshake.

## Advanced configuration

This add-on's options cover the common cases. For anything else — TLS, ACLs,
username/password auth, broker-to-broker bridges, OTLP export — drop a
`wispmq.toml` into this add-on's config folder (Settings → Add-ons →
WispMQ → ⋮ → Show in sidebar isn't needed; the folder is
`/addon_configs/<addon_slug>/wispmq.toml` on the host, reachable through the
Samba/File Editor/Studio Code Server add-ons). When present, it's loaded and
every option in it takes effect — see the
[main repo's Configuration section](https://github.com/elpapimango/wispmq#configuration)
for the full key list.

## Data

The broker's SQLite database (retained messages, persistent sessions) lives
in this add-on's own persistent `/data` — it survives add-on restarts and
Home Assistant updates, but is removed if you uninstall the add-on.
