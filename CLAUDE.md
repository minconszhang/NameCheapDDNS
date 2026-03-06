# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A single-file Bash utility that automatically updates Cloudflare DNS A records when the host's public IP changes. Designed to run unattended via cron or Docker.

## Running

```bash
# Setup: copy env template and fill in credentials
cp .env.example .env

# Run manually
./update_ddns.sh

# Run with Docker
docker compose up -d

# View logs
docker compose logs -f
```

There is no test suite or linter.

## Architecture

**`update_ddns.sh`** — the entire application:
1. Loads config from `.env` (CF_API_TOKEN, CF_ZONE_ID, DOMAIN, HOSTS)
2. Fetches public IP from `api.ipify.org` via curl
3. Compares against the last recorded IP in `.prev_ip`
4. If IP changed, for each host: looks up the A record ID via Cloudflare API, then PUTs the new IP
5. Saves current IP to `.prev_ip`; all output goes to stdout/stderr (visible via `docker compose logs`)

**`.env`** — runtime configuration (not committed):
- `CF_API_TOKEN` — Cloudflare API token with Zone.DNS Edit permission
- `CF_ZONE_ID` — Cloudflare Zone ID (found on domain overview page)
- `DOMAIN` — registered domain name
- `HOSTS` — space-separated list of host records (`@` for root, `www`, etc.)

## Key Behaviors

- Script logs IP status every run; only calls Cloudflare API when IP changes
- Every ~10 minutes, performs a status check: queries Cloudflare for each A record and compares against the current public IP
- Output goes to stdout/stderr, visible via `docker compose logs`
- Comments in the script are in Chinese (Simplified)
- The script `cd`s to its own directory on startup, so paths are relative to the script location
