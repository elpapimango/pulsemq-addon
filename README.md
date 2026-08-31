# WispMQ Add-ons

Home Assistant Supervisor add-on for [WispMQ](https://github.com/elpapimango/wispmq),
an MQTT v5.0 / v3.1.1 / v3.1 broker written in Rust. Wraps the project's own
published multi-arch image (`ghcr.io/elpapimango/wispmq`) unchanged — no
separate build of the broker happens in this repo.

## Install

1. In Home Assistant: **Settings → Add-ons → Add-on Store → ⋮ → Repositories**.
2. Add `https://github.com/elpapimango/wispmq-addon`.
3. Install **WispMQ** from the store, then start it.
4. Connect Home Assistant's built-in **MQTT** integration to it
   (`<your-ha-host>:1883`) to get [MQTT Discovery](https://github.com/elpapimango/wispmq#home-assistant-mqtt-discovery)
   sensors (clients connected, retained messages, publish throughput, ...)
   with no extra setup — the add-on has `ha_discovery` on by default.

Full option reference: [`wispmq/DOCS.md`](wispmq/DOCS.md) (also shown in
the add-on's own Documentation tab once installed).

## Versioning

This add-on's version tracks the [wispmq](https://github.com/elpapimango/wispmq)
release it wraps. See [`wispmq/CHANGELOG.md`](wispmq/CHANGELOG.md).
