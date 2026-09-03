# Changelog

## 0.9.6

- **Fix: add-on failed to start at all**, no logs beyond repeated
  `jq: error: Could not open file /data/options.json: Permission denied`.
  `Dockerfile` dropped to the base image's non-root `USER 10001` before
  running `run.sh`, but Supervisor writes `/data/options.json` `0600`
  (root-only) — so every `jq`/`opt()` read in `run.sh` failed, silently
  under `sh`'s `set -e` (a failing command inside `$(...)` doesn't trigger
  it), and the broker launched with every option empty. Dropped the `USER`
  override entirely; `run.sh` (and, as a result, `wispmq` itself) now runs
  as root inside this add-on, matching the official Mosquitto add-on and
  the standard pattern for HA add-on entrypoints — Supervisor's own
  container/AppArmor sandboxing is the isolation boundary, not an
  in-container UID. Verified by building the image locally and running it
  against a root-owned `0600 options.json`: the old image reproduced the
  exact reported error, the fixed one starts clean, loads the `logins`
  credential, and answers `/health`.

## 0.9.5

- New `logins` option: a repeatable username/password list (Settings →
  Add-ons → WispMQ → Configuration), mirroring the official Mosquitto broker
  add-on's own "logins" option. `run.sh` regenerates `/data/passwd` from it
  on every start via `wispmq --hash-password` (using its `MQTT_HASH_PASSWORD`
  env-var fallback for non-interactive hashing) and exports
  `MQTT_PASSWORD_FILE` — only when `logins` is non-empty, so an add-on with
  no logins configured behaves exactly as before. Per-user ACLs are still
  advanced-only (a dropped-in `acl.toml`).
- Follows the broker's ACL file switching from JSON to TOML (wispmq 0.9.5):
  the Advanced-configuration note now says `acl.toml`, not `acl.json`.

## 0.9.4

- Follows the broker's `pulsemq` → `wispmq` rename (name collision with
  other projects): this add-on's repo, slug, and image reference all moved
  to `wispmq`. `Dockerfile` now pulls
  `ghcr.io/elpapimango/wispmq:latest` — floating, not pinned to a version
  tag, because no `wispmq` release has been tagged yet (the last tagged
  broker release, `0.9.3`, only ever published as
  `ghcr.io/elpapimango/pulsemq:0.9.3`; nothing republishes it under the new
  name). Re-pin once `wispmq` cuts its first tagged post-rename release.
- `run.sh`'s custom-config path comment now says `/config/wispmq.toml`
  (the broker's default config filename renamed along with everything else;
  the `MQTT_*` option env vars themselves are unchanged).

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
