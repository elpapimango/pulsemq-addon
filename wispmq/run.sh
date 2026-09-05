#!/bin/sh
set -e

OPTIONS=/data/options.json
CUSTOM_CONFIG=/config/wispmq.toml

opt() { jq -r ".$1" "$OPTIONS"; }

# A user-supplied wispmq.toml (dropped into the add-on's own config folder,
# exposed at /config via the addon_config map) takes over the full config
# pipeline unchanged — everything this add-on's options don't expose (ACLs,
# bridges, OTLP, ...) is still reachable this way.
if [ -f "$CUSTOM_CONFIG" ]; then
    echo "[wispmq-addon] using custom config file: $CUSTOM_CONFIG"
    export MQTT_CONFIG_FILE="$CUSTOM_CONFIG"
fi

export MQTT_ALLOW_ANONYMOUS="$(opt allow_anonymous)"
export MQTT_MAX_CONNECTIONS_PER_IP="$(opt max_connections_per_ip)"
export MQTT_SYS_INTERVAL="$(opt sys_interval)"
export MQTT_HA_DISCOVERY="$(opt ha_discovery)"
export MQTT_HA_DISCOVERY_PREFIX="$(opt ha_discovery_prefix)"
export RUST_LOG="$(opt log_level)"

token="$(opt admin_token)"
if [ -n "$token" ] && [ "$token" != "null" ]; then
    export MQTT_ADMIN_TOKEN="$token"
fi

# Regenerate the password file from the "logins" option on every boot, so
# options.json stays the single source of truth (removing a login in the UI
# actually removes their access, rather than leaving a stale credential
# behind). No logins configured => no password file, same as today.
LOGIN_COUNT="$(jq -r '.logins | length' "$OPTIONS")"
if [ "$LOGIN_COUNT" -gt 0 ]; then
    PASSWD_FILE=/data/passwd
    : > "$PASSWD_FILE"
    i=0
    while [ "$i" -lt "$LOGIN_COUNT" ]; do
        username="$(jq -r ".logins[$i].username" "$OPTIONS")"
        password="$(jq -r ".logins[$i].password" "$OPTIONS")"
        MQTT_HASH_PASSWORD="$password" wispmq --hash-password "$username" >> "$PASSWD_FILE"
        i=$((i + 1))
    done
    chmod 600 "$PASSWD_FILE"
    export MQTT_PASSWORD_FILE="$PASSWD_FILE"
fi

# TLS/mTLS certs are referenced by filename against Home Assistant's shared
# /ssl folder (mapped read-only above) — the same folder most setups already
# have a cert in for HA's own HTTPS, hence certfile/keyfile defaulting to the
# fullchain.pem/privkey.pem names that convention (and the Let's Encrypt
# add-on) uses. Each *_cafile is optional on top of a cert+key: setting it
# requires (mutual TLS) a trusted client certificate on that listener; wispmq
# itself rejects a cafile set without a matching cert+key, so no extra
# validation is needed here.
cert_arg() {
    file="$(opt "$1")"
    if [ -n "$file" ] && [ "$file" != "null" ]; then
        export "$2=/ssl/$file"
    fi
}

# The two plain listeners are unconditional, exactly like the official
# Mosquitto add-on's Network card. The two dedicated TLS listeners are
# NOT unconditional, unlike an earlier version of this comment claimed:
# wispmq (0.9.6+) hard-fails at startup if a *_TLS_LISTEN_ADDR is set
# without its matching cert+key (Config::validate — a deliberate
# fail-closed design, not something this add-on should route around), so
# each TLS listen address is only exported at all once both its cert and
# key resolve under /ssl. A fresh install with nothing in /ssl yet runs
# only the two plain listeners; dropping a cert+key pair into /ssl and
# restarting brings the matching TLS listener up.
export MQTT_WS_LISTEN_ADDR="0.0.0.0:1884"

tls_certfile="$(opt certfile)"
tls_keyfile="$(opt keyfile)"
if [ -n "$tls_certfile" ] && [ "$tls_certfile" != "null" ] && [ -n "$tls_keyfile" ] && [ "$tls_keyfile" != "null" ]; then
    export MQTT_TLS_LISTEN_ADDR="0.0.0.0:8883"
    export MQTT_TLS_CERT="/ssl/$tls_certfile"
    export MQTT_TLS_KEY="/ssl/$tls_keyfile"
    cert_arg cafile MQTT_TLS_CLIENT_CA
fi

ws_certfile="$(opt ws_certfile)"
ws_keyfile="$(opt ws_keyfile)"
if [ -n "$ws_certfile" ] && [ "$ws_certfile" != "null" ] && [ -n "$ws_keyfile" ] && [ "$ws_keyfile" != "null" ]; then
    export MQTT_WS_TLS_LISTEN_ADDR="0.0.0.0:8884"
    export MQTT_WS_TLS_CERT="/ssl/$ws_certfile"
    export MQTT_WS_TLS_KEY="/ssl/$ws_keyfile"
    cert_arg ws_cafile MQTT_WS_TLS_CLIENT_CA
fi

if [ "$(opt admin_tls)" = "true" ]; then
    cert_arg admin_certfile MQTT_ADMIN_TLS_CERT
    cert_arg admin_keyfile MQTT_ADMIN_TLS_KEY
    cert_arg admin_cafile MQTT_ADMIN_TLS_CLIENT_CA
fi

exec wispmq
