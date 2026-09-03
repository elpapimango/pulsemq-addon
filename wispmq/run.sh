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
# have a cert in for HA's own HTTPS. Each *_cafile is optional on top of its
# cert+key: setting it requires (mutual TLS) a trusted client certificate on
# that listener; wispmq itself rejects a cafile set without a matching
# cert+key, so no extra validation is needed here.
cert_arg() {
    file="$(opt "$1")"
    if [ -n "$file" ] && [ "$file" != "null" ]; then
        export "$2=/ssl/$file"
    fi
}
cert_arg certfile MQTT_TLS_CERT
cert_arg keyfile MQTT_TLS_KEY
cert_arg cafile MQTT_TLS_CLIENT_CA

if [ "$(opt websocket)" = "true" ]; then
    export MQTT_WS_LISTEN_ADDR="0.0.0.0:8080"
    cert_arg ws_certfile MQTT_WS_TLS_CERT
    cert_arg ws_keyfile MQTT_WS_TLS_KEY
    cert_arg ws_cafile MQTT_WS_TLS_CLIENT_CA
fi

cert_arg admin_certfile MQTT_ADMIN_TLS_CERT
cert_arg admin_keyfile MQTT_ADMIN_TLS_KEY
cert_arg admin_cafile MQTT_ADMIN_TLS_CLIENT_CA

exec wispmq
