# Thin wrapper: reuses the already-published, multi-arch wispmq image
# (github.com/elpapimango/wispmq) as-is and only adds the glue needed to
# read Home Assistant's add-on options. No Rust build happens here.
#
# Pinned to a real version tag (wispmq's first tagged post-rename release),
# not :latest — this add-on requires 0.9.6+ for the dedicated TLS listener
# addresses (tls_listen_addr/ws_tls_listen_addr) to have any effect; an
# older or a future-but-untested wispmq image should not silently become
# this add-on's base just because someone pushed to wispmq's main branch.
# Bump this deliberately when a newer wispmq release has been checked
# against this add-on's config/run.sh.
FROM ghcr.io/elpapimango/wispmq:0.9.8

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod +x /run.sh

# Stay root: Supervisor writes /data/options.json 0600 (root-only), so
# run.sh's jq reads need root — dropping to the base image's non-root uid
# 10001 here (as earlier versions did) makes every jq call in run.sh fail
# with "Permission denied", and the add-on never starts. USER applies to
# whatever this ENTRYPOINT ultimately execs into, so wispmq itself now runs
# as root too inside this add-on (not the standalone wispmq image's own
# non-root default) — the standard tradeoff for HA add-on entrypoints;
# the official Mosquitto add-on runs the same way (no USER override at
# all). Supervisor's own container/AppArmor sandboxing is the isolation
# boundary here, not an in-container UID.
ENTRYPOINT ["/run.sh"]
