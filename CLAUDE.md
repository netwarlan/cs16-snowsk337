# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Dockerized Counter-Strike 1.6 server configured specifically for the AWP SnowSk337 map. Part of the NETWAR LAN event infrastructure. Published to `ghcr.io/netwarlan/cs16-snowsk337`.

## Commands

```bash
./build.sh              # Build Docker image (wraps: docker build -t ghcr.io/netwarlan/cs16-snowsk337 .)
./build.sh --no-cache   # Rebuild without cache; extra args passed through via "$@"
```

Run locally for testing:
```bash
docker run -it \
  -p 27015:27015/udp \
  -p 27015:27015/tcp \
  -e CS16_SERVER_HOSTNAME="DOCKER SNOWSK337" \
  -e CS16_SERVER_UPDATE_ON_START=true \
  ghcr.io/netwarlan/cs16-snowsk337
```

First run **must** set `CS16_SERVER_UPDATE_ON_START=true` to download game files via SteamCMD. Subsequent runs can set it to `false` if using a persistent volume.

## Architecture

Three files make up the entire project:

- **`Dockerfile`** — Debian 13-slim base, installs i386 libraries (CS 1.6 is 32-bit), sets up SteamCMD, creates non-root `steam` user, symlinks `~/.steam/sdk32`
- **`run.sh`** — Entrypoint script: sets env var defaults → validates numeric inputs → optionally downloads game files only and exits → optionally updates game via SteamCMD → generates `server.cfg` from env vars → optionally downloads remote config override → launches `hlds_run`
- **`build.sh`** — Thin wrapper around `docker build`

### SteamCMD Manifest Workaround

CS 1.6 (app ID 90) has a known SteamCMD bug requiring a two-pass download. The `run.sh` update sequence:
1. First SteamCMD pass to download base files
2. Delete `steamapps/` manifests
3. Fetch correct manifests (app IDs 10, 70, 90) from `dgibbs64/HLDS-appmanifest` on GitHub
4. Second SteamCMD pass with `+app_set_config 90 mod cstrike` to complete the install

After game download, the script also fetches the `awp_snowsk337` map from `netwarlan/map-files` repo, replaces all existing maps, and sets a single-map mapcycle.

### Config Generation

The server config is generated via heredoc into `$GAME_DIR/cstrike/server.cfg`. If `CS16_SERVER_REMOTE_CFG` is set, a remote config is downloaded and used instead (overriding the generated one). The remote config filename becomes the new `CS16_SERVER_CONFIG` value.

## Environment Variables

All prefixed with `CS16_`. Key variables and their defaults:

| Variable | Default | Notes |
|---|---|---|
| `CS16_SERVER_PORT` | 27015 | Validated as numeric |
| `CS16_SERVER_MAXPLAYERS` | 32 | Validated as numeric |
| `CS16_SERVER_MAP` | awp_snowsk337 | |
| `CS16_SERVER_HOSTNAME` | SnowSk337 Server | |
| `CS16_SVLAN` | 0 | Set to 0 for internet play |
| `CS16_SERVER_UPDATE_ON_START` | false | Must be true on first run |
| `CS16_SERVER_VALIDATE_ON_START` | false | Adds `validate` flag to SteamCMD |
| `CS16_SERVER_UPDATE_ONLY_THEN_STOP` | false | Download game files then exit without starting server |
| `CS16_SERVER_VALIDATE_ONLY_THEN_STOP` | false | Validate game files then exit without starting server |
| `CS16_SERVER_PW` | (unset) | Only written to config if set |
| `CS16_SERVER_RCONPW` | (unset) | Only written to config if set |
| `CS16_SERVER_FASTDOWNLOAD_URL` | (unset) | Sets `sv_downloadurl` if set |
| `CS16_SERVER_REMOTE_CFG` | (unset) | URL to download config override |
| `CS16_SERVER_CONFIG` | server.cfg | Config filename for `+exec` |

## CI/CD

Three-job GitHub Actions workflow (`.github/workflows/build.yml`):
1. **version** — runs `netwarlan/action-semantic-versioning@v1` in dry-run mode to calculate semver from conventional commits
2. **build** — builds and pushes Docker image to GHCR with tags: branch name, `latest` (on main), git SHA, and semantic version (when available)
3. **release** — creates a GitHub release with changelog when a new version is calculated

Triggers on push to `main` and manual dispatch. Uses conventional commits for version bumps: `fix:` → patch, `feat:` → minor, `BREAKING CHANGE:` → major. Non-conventional commits also bump patch (`bump-patch-on-unknown: true`).

## Conventions

- Shell scripts use `set -e` for fail-fast
- Env var defaults use `${VAR:-default}` style
- Numeric env vars validated with regex (`=~ ^[0-9]+$`)
- Container runs as non-root `steam` user
- Healthcheck monitors `hlds_linux` process via `pgrep`
- Docker log rotation: `max-size: "10m"`, `max-file: "3"` (configured in compose at deployment level)
