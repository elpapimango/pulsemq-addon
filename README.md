# PulseMQ Add-ons

Home Assistant Supervisor add-on for [PulseMQ](https://github.com/elpapimango/pulsemq),
an MQTT v5.0 / v3.1.1 / v3.1 broker written in Rust. Wraps the project's own
published multi-arch image (`ghcr.io/elpapimango/pulsemq`) unchanged — no
separate build of the broker happens in this repo.

## Install

1. In Home Assistant: **Settings → Add-ons → Add-on Store → ⋮ → Repositories**.
2. Add `https://github.com/elpapimango/pulsemq-addon`.
3. Install **PulseMQ** from the store, then start it.
4. Connect Home Assistant's built-in **MQTT** integration to it
   (`<your-ha-host>:1883`) to get [MQTT Discovery](https://github.com/elpapimango/pulsemq#home-assistant-mqtt-discovery)
   sensors (clients connected, retained messages, publish throughput, ...)
   with no extra setup — the add-on has `ha_discovery` on by default.

Full option reference: [`pulsemq/DOCS.md`](pulsemq/DOCS.md) (also shown in
the add-on's own Documentation tab once installed).

## Versioning

This add-on's version tracks the [pulsemq](https://github.com/elpapimango/pulsemq)
release it wraps. See [`pulsemq/CHANGELOG.md`](pulsemq/CHANGELOG.md).
