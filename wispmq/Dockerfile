# Thin wrapper: reuses the already-published, multi-arch wispmq image
# (github.com/elpapimango/wispmq) as-is and only adds the glue needed to
# read Home Assistant's add-on options. No Rust build happens here.
#
# Pinned to :latest, not a version tag: this add-on wrapped pulsemq:0.9.3
# before the pulsemq -> wispmq rename, and no wispmq:0.9.3 image exists (or
# ever will) under the new name. Re-pin to a real version tag once wispmq
# cuts its first tagged post-rename release.
FROM ghcr.io/elpapimango/wispmq:latest

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod +x /run.sh

USER 10001
ENTRYPOINT ["/run.sh"]
