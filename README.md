# NameCheapDDNS

A lightweight Dynamic DNS (DDNS) solution for automatically updating DNS records using NameCheap's API.

## Overview

This project provides an automated way to keep your domain's A records synchronized with your dynamic IP address. By periodically detecting your public IP and updating NameCheap's DNS records, your services remain reachable even when your ISP changes your IP.

## Features

- Automatic public IP detection
- Integration with NameCheap's Dynamic DNS API
- Configurable update interval via cron
- Support for multiple host records (e.g., @, www, or custom subdomains)
- Detailed logging and error reporting

## Prerequisites

- A registered domain on NameCheap with DDNS enabled
- Your Dynamic DNS password from NameCheap's Advanced DNS > Dynamic DNS panel
- A Unix-like environment (macOS, Linux) with bash, curl, and cron
- Basic familiarity with shell scripting and cron jobs

## Installation

1. Clone the repository:

```bash
git clone https://github.com/minconszhang/NameCheapDDNS.git
```

2. Make the update script executable:

```bash
chmod +x update_ddns.sh
```

3. Create a copy of the example environment file:

```bash
cp .env.example .env
```

## Configuration

Edit the `.env` file in the project root and configure your settings:

# .env

- DOMAIN: Your registered domain name
- PASSWORD: The Dynamic DNS password from NameCheap
- IP: (Optional) Specify an IP address instead of auto-detection
- HOSTS: List of hostnames (@ for root, www, etc.)

## Usage

### Manual Run

```bash
./update_ddns.sh
```

Check `ddns.log` for detailed output and any errors.

### Automate with Cron

1. Open your crontab with:

```bash
crontab -e
```

2. Add a new line to run the script every 10 minutes (adjust interval as needed):

```bash
*/10 * * * * /pathtofile/NameCheapDDNS/update_ddns.sh
```

3. Save and exit, then verify:

```bash
crontab -l
```

The script will now execute at the specified interval.

## Logging

ddns.log: Per-run details including timestamps, hostnames, and API responses

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
