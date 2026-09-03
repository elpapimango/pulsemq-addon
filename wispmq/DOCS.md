# WispMQ

An MQTT v5.0 / v3.1.1 / v3.1 broker, built directly from the OASIS specs. This
add-on wraps the [official wispmq image](https://github.com/elpapimango/wispmq)
unchanged — see that repo for the full option/environment-variable reference
and protocol details.

## Ports

- `1883/tcp` — MQTT: plain, or TLS/mTLS once `certfile`/`keyfile` are set
- `8080/tcp` — MQTT over WebSocket: only listens when `websocket` is on;
  plain, or WSS/mTLS once `ws_certfile`/`ws_keyfile` are set
- `9001/tcp` — Admin HTTP: `/health`, Prometheus `/metrics`, MCP; plain, or
  HTTPS/mTLS once `admin_certfile`/`admin_keyfile` are set

## Options

| Option | Default | Meaning |
|---|---|---|
| `logins` | _(empty)_ | Username/password credentials MQTT clients can authenticate with — add one row per user. Leave empty to allow only anonymous access (per `allow_anonymous`) |
| `allow_anonymous` | `true` | Allow clients to connect without credentials |
| `max_connections_per_ip` | `0` | Max new connections per source IP per 10s window; `0` = unlimited |
| `sys_interval` | `10` | `$SYS/broker/...` status refresh interval (s); `0` disables it |
| `ha_discovery` | `true` | Publish Home Assistant MQTT Discovery config + state topics for every broker statistic — Home Assistant's own MQTT integration then auto-creates sensor entities (clients connected, retained messages, publish throughput, ...) with no further setup |
| `ha_discovery_prefix` | `homeassistant` | Must match Home Assistant's own discovery prefix (only change this if you changed it there) |
| `admin_token` | _(unset)_ | Bearer token required on `/metrics` and MCP; leave blank while the admin port is only reachable from inside your network |
| `log_level` | `info` | `trace` / `debug` / `info` / `warn` / `error` |
| `websocket` | `false` | Enable the MQTT-over-WebSocket listener on `8080/tcp` |
| `certfile` / `keyfile` | _(unset)_ | Filenames in `/ssl` — both set = TLS on the MQTT port (`1883`) |
| `cafile` | _(unset)_ | Filename in `/ssl` — set = require a trusted client certificate on the MQTT port (mutual TLS) |
| `ws_certfile` / `ws_keyfile` | _(unset)_ | Same, for the WebSocket port (`8080`); ignored unless `websocket` is on |
| `ws_cafile` | _(unset)_ | Mutual TLS on the WebSocket port |
| `admin_certfile` / `admin_keyfile` | _(unset)_ | Same, for the admin port (`9001`) |
| `admin_cafile` | _(unset)_ | Mutual TLS on the admin port |

## Managing users

Add rows under `logins` (Settings → Add-ons → WispMQ → Configuration) to
require username/password authentication — each client must then present one
of these credentials on CONNECT, or `0x86`/`0x87` is returned. The password
file is regenerated from `logins` on every add-on start, so removing a row
and restarting actually revokes that user; it isn't something you edit by
hand. With `logins` empty (the default), the broker takes clients exactly as
before — anonymous, if `allow_anonymous` is on.

`allow_anonymous` still governs credential-less clients when `logins` is
non-empty: a client that sends no username can still connect as `anonymous`
if `allow_anonymous: true`, but any client that *does* send a username must
authenticate against `logins`. Per-user topic permissions (ACLs) aren't
configurable from this UI — drop a custom `acl.toml` via the Advanced
configuration option below to restrict what each user can publish/subscribe
to.

## TLS & mTLS

Drop your certificate and key into Home Assistant's shared `/ssl` folder —
the same one most setups already have a cert in for HA's own HTTPS, or for
other add-ons (reachable through the Samba/File Editor/Studio Code Server
add-ons). Then reference the filenames (not full paths) in the matching
option: `certfile`/`keyfile` for the MQTT port, `ws_certfile`/`ws_keyfile`
for the WebSocket port (also needs `websocket: true`), `admin_certfile`/
`admin_keyfile` for the admin port. Each is independent — set only the ones
for the listeners you're exposing.

Setting the matching `cafile` option on top of a cert+key requires clients
on that listener to present a certificate signed by that CA (mutual TLS) —
a client with no certificate, or one from an untrusted CA, is rejected at
the TLS handshake. A `cafile` set without a `certfile`/`keyfile` on the same
listener is a startup error (a client CA is meaningless without the server
side of TLS being on too).

## Enabling MQTT Discovery in Home Assistant

Home Assistant's built-in **MQTT** integration (Settings → Devices & Services
→ Add Integration → MQTT) needs to be connected to this broker
(`<your-ha-host>:1883`) for the discovered sensors to appear. Discovery is on
by default on the Home Assistant side; this add-on's `ha_discovery: true`
option is the broker-side half of that handshake.

## Advanced configuration

This add-on's options cover the common cases. For anything else — ACLs,
broker-to-broker bridges, OTLP export — drop a `wispmq.toml` (and, for ACLs,
an `acl.toml`) into this add-on's config folder (Settings → Add-ons →
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
