# Thin wrapper: reuses the already-published, multi-arch pulsemq image
# (github.com/elpapimango/pulsemq) as-is and only adds the glue needed to
# read Home Assistant's add-on options. No Rust build happens here.
FROM ghcr.io/elpapimango/pulsemq:0.9.3

USER root
RUN apt-get update \
    && apt-get install -y --no-install-recommends jq \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod +x /run.sh

USER 10001
ENTRYPOINT ["/run.sh"]
