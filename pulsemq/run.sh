#!/bin/sh
set -e

OPTIONS=/data/options.json
CUSTOM_CONFIG=/config/pulsemq.toml

opt() { jq -r ".$1" "$OPTIONS"; }

# A user-supplied pulsemq.toml (dropped into the add-on's own config folder,
# exposed at /config via the addon_config map) takes over the full config
# pipeline unchanged — everything this add-on's options don't expose (ACLs,
# TLS, bridges, OTLP, ...) is still reachable this way.
if [ -f "$CUSTOM_CONFIG" ]; then
    echo "[pulsemq-addon] using custom config file: $CUSTOM_CONFIG"
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

exec pulsemq
