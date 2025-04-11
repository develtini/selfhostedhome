# Self-Hosted Home Server

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-private-red.svg)

A Docker Compose setup for managing self-hosted services in a private home server environment, using Traefik as reverse proxy.

## Architecture

This system uses Traefik as the entry point with:
- Port 443: LAN access with Let's Encrypt certificate
- Port 8443: External access via Cloudflare tunnel (useful for CG-NAT topology)

## Services

## 🧩 Services Overview

| Service        | Image                 | Purpose                                                                 |
|----------------|-----------------------|-------------------------------------------------------------------------|
| **Traefik**     | `traefik:3.3`          | Reverse proxy, routing, and automatic SSL certificate management.       |
| **Pihole**      | `pihole:latest`        | DNS sinkhole for ads and tracking domains.                             |
| **Navidrome**   | `navidrome:latest`     | Lightweight, web-based music server compatible with Subsonic clients.  |
| **Jellyfin**    | `jellyfin:latest`      | Media server for streaming movies, shows, and music.                   |
| **Radarr**      | `linuxserver/radarr`   | Movie collection manager with automated downloads and organization.    |
| **Sonarr**      | `linuxserver/sonarr`   | Series manager with support for episode tracking and automatic grabbing.|
| **Jackett**     | `linuxserver/jackett`  | Proxy indexer that translates queries for public/private torrent sites.|
| **Flaresolverr**| `ghcr.io/flaresolverr/flaresolverr:latest` | CAPTCHA-solving proxy for bypassing Cloudflare protection. |
| **Transmission**| `linuxserver/transmission` | Lightweight and efficient BitTorrent client with web UI.       |

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

## 🛠️ Makefile Commands

### 🚀 Service Lifecycle

| Command                             | Description                                                   |
|------------------------------------|---------------------------------------------------------------|
| `make start`                       | Start Traefik, Pi-hole, and all active services.              |
| `make start-base`                  | Start base services (Traefik and Pi-hole).                    |
| `make start-all-services`          | Start all active services configured in `.env`.               |
| `make start-service SERVICE=name`  | Start a specific service.                                     |
| `make stop`                        | Stop all services (Traefik, Pi-hole, and active services).    |
| `make stop-base`                   | Stop base services (Traefik and Pi-hole).                     |
| `make stop-all-services`           | Stop all active services.                                     |
| `make stop-service SERVICE=name`   | Stop a specific service.                                      |
| `make restart`                     | Restart all services.                                         |
| `make restart-services`            | Restart all active services.                                  |

---

### 📋 Logs Management

| Command                             | Description                                                  |
|------------------------------------|--------------------------------------------------------------|
| `make logs`                        | Show logs for all services (base + active).                  |
| `make logs-base`                   | Show logs for Traefik and Pi-hole.                           |
| `make logs-all-services`           | Show logs for all active services.                           |
| `make logs-service SERVICE=name`   | Show logs for a specific service.                            |
| `make logs-traefik`                | Show logs for Traefik.                                       |
| `make logs-traefik-access`         | Show Traefik access logs (`tail -f /var/log/traefik/...`).   |
| `make logs-pihole`                 | Show logs for Pi-hole.                                       |
| `make logs-pihole-dns`             | Show DNS logs for Pi-hole.                                   |
| `make logs-navidrome`              | Show logs for Navidrome.                                     |
| `make logs-jellyfin`               | Show logs for Jellyfin.                                      |
| `make logs-radarr`                 | Show logs for Radarr.                                        |
| `make logs-sonarr`                 | Show logs for Sonarr.                                        |
| `make logs-jackett`                | Show logs for Jackett.                                       |
| `make logs-flaresolverr`           | Show logs for Flaresolverr.                                  |
| `make logs-transmission`           | Show logs for Transmission.                                  |

---

### 🐚 Shell Access

| Command                      | Description                                 |
|-----------------------------|---------------------------------------------|
| `make shell-traefik`        | Open a shell in the Traefik container.     |
| `make shell-pihole`         | Open a shell in the Pi-hole container.     |
| `make shell-jellyfin`       | Open a shell in the Jellyfin container.    |
| `make shell-radarr`         | Open a shell in the Radarr container.      |
| `make shell-sonarr`         | Open a shell in the Sonarr container.      |
| `make shell-jackett`        | Open a shell in the Jackett container.     |
| `make shell-flaresolverr`   | Open a shell in the Flaresolverr container.|
| `make shell-transmission`   | Open a shell in the Transmission container.|

---

### ⚙️ Custom Service Commands

| Command                          | Description                          |
|----------------------------------|--------------------------------------|
| `make cmd-pihole-localdns`       | Update local DNS entries.           |
| `make cmd-pihole-adlists`        | Add adlists to Pi-hole.             |
| `make cmd-pihole-adlists-clean`  | Clean Pi-hole adlists.              |
| `make cmd-pihole-flushdns`       | Flush Pi-hole DNS cache.            |
| `make cmd-jellyfin-checkhw`      | Check Jellyfin hardware acceleration.|

---

### 🔧 Utilities

| Command      | Description                                       |
|--------------|---------------------------------------------------|
| `make help`  | Show help information for all commands.           |
| `make list`  | List all active services configured in `.env`.    |


## License

This project is private and not licensed for public use. All rights reserved.


## FAQ

### Q: I'm having trouble generating the Let's Encrypt certificate.  🔐
**A:** The issue might be caused by the default configuration enabling the Cloudflared certificate. To resolve the problem, disable the Cloudflared certificate in your configuration `tls.yml` so that the Let's Encrypt certificate can be generated successfully.



## References Block Lists:

[https://github.com/hagezi/dns-blocklists](https://github.com/hagezi/dns-blocklists)