# Self-Hosted Home Server

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-private-red.svg)

A Docker Compose setup for managing self-hosted services in a private home server environment, using Traefik as reverse proxy.

## Architecture

This system uses Traefik as the entry point with:
- Port 443: LAN access with Let's Encrypt certificate
- Port 8443: External access via Cloudflare tunnel (useful for CG-NAT topology)

## Services

| Service | Image | Purpose |
|---------|-------|---------|
| Traefik | `traefik:3.3` | Reverse proxy and certificate management |
| Navidrome | `navidrome:latest` | Web-based music collection server and streamer
## Requirements

- Docker
- Docker Compose
- Makefile
- Domain name with DNS properly configured
- Cloudflare account (if using tunnel functionality)
- Cloudflared Tunnel Service

## Installation

1. Clone the repository:
   ```bash
   git clone <REPOSITORY_URL>
   cd docker
   ```

2. Check all `.env.sample` files in the project and copy them to `.env` files. The one in the root directory is mandatory.

3. Start the system:
   ```bash
   make start
   ```

## Usage

### Makefile Commands

| Command | Description |
|---------|-------------|
| `make start` | Start all services |
| `make stop` | Stop all services |
| `make restart` | Restart all services |
| `make logs` | View container logs |
| `make list` | List active services |

## License

This project is private and not licensed for public use. All rights reserved.