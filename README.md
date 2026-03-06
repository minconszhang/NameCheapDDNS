# Cloudflare DDNS

A lightweight Dynamic DNS (DDNS) solution for automatically updating Cloudflare DNS A records when your public IP changes.

## Overview

This project provides an automated way to keep your domain's A records synchronized with your dynamic IP address. It periodically detects your public IP and updates Cloudflare's DNS records, so your services remain reachable even when your ISP changes your IP.

## Features

- Automatic public IP detection via [ipify](https://api.ipify.org)
- Integration with the Cloudflare DNS API
- Docker-based deployment with automatic 60-second update interval
- Support for multiple host records (e.g., `@`, `www`, or custom subdomains)
- Periodic status checks every ~10 minutes to verify DNS records match the current IP
- Only calls the Cloudflare API when an IP change is detected

## Prerequisites

- A domain managed by Cloudflare
- A Cloudflare API token with **Zone.DNS Edit** permission
- Docker and Docker Compose (for containerized deployment), or a Unix-like environment with `bash` and `curl`

## Installation

1. Clone the repository:

```bash
git clone https://github.com/minconszhang/NameCheapDDNS.git
cd NameCheapDDNS
```

2. Create a copy of the example environment file and fill in your credentials:

```bash
cp .env.example .env
```

## Configuration

Edit the `.env` file with your Cloudflare settings:

| Variable       | Description                                                        |
| -------------- | ------------------------------------------------------------------ |
| `CF_API_TOKEN` | Cloudflare API token with Zone.DNS Edit permission                 |
| `CF_ZONE_ID`   | Cloudflare Zone ID (found on your domain's overview page)          |
| `DOMAIN`       | Your registered domain name (e.g., `example.com`)                  |
| `HOSTS`        | Space-separated list of host records (`@` for root, `www`, etc.)   |

## Usage

### Docker (recommended)

```bash
docker compose up -d
```

View logs:

```bash
docker compose logs -f
```

### Manual Run

```bash
./update_ddns.sh
```

## How It Works

1. Fetches your public IP from `api.ipify.org`
2. Compares it against the last recorded IP (stored in `.prev_ip`)
3. If the IP changed, looks up each A record via the Cloudflare API and updates it
4. Every ~10 runs (~10 minutes), performs a status check to verify all DNS records match the current IP

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
