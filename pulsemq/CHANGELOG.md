# Changelog

## 0.9.3

- Follows pulsemq's config file switch from JSON to TOML: `run.sh` now looks
  for a custom config at `/config/pulsemq.toml` (was `pulsemq.json`).
- `Dockerfile` now pins `ghcr.io/elpapimango/pulsemq:0.9.3`. The `0.9.2` entry
  below referenced `ghcr.io/elpapimango/pulsemq:0.9.2`, which was never
  actually published — pulsemq's `docker.yml` only tags a bare version number
  on an actual `vX.Y.Z` git tag push, and 0.9.2 wasn't (see `CLAUDE.md` in the
  main repo). `v0.9.3` *was* tagged and released, so the bare-version tag now
  exists for real.

## 0.9.2

Initial release. Wraps [`ghcr.io/elpapimango/pulsemq`](https://github.com/elpapimango/pulsemq/pkgs/container/pulsemq)
unchanged, adding Home Assistant option handling and MQTT Discovery
(`ha_discovery`, on by default in this add-on).
