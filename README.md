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
| Navidrome | `navidrome:latest` | Web-based music collection server and streamer |
| Pihole | `pihole:latest` |  DNS sinkhole |
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

## 🚀 Makefile Usage

This project provides a robust `Makefile` to manage various Docker services such as **Traefik**, **Pihole**, and other active services configured through an `.env` file. The available commands are designed to simplify service management, logging, and interaction.

### 📋 Service Management

| Command                    | Description                                                 |
|----------------------------|-------------------------------------------------------------|
| `make start`               | Start all services (Traefik, Pihole, and active services).  |
| `make start-base`          | Start only common services (Traefik and Pihole).            |
| `make start-all-services`  | Start all active services defined in `.env`.                |
| `make start-service`       | Start a specific service (`SERVICE=<service_name>`).        |
| `make stop`                | Stop all services (Traefik, Pihole, and active services).   |
| `make stop-base`           | Stop only common services (Traefik and Pihole).             |
| `make stop-all-services`   | Stop all active services.                                    |
| `make stop-service`        | Stop a specific service (`SERVICE=<service_name>`).         |
| `make restart`             | Restart all services.                                       |

---

### 📋 Logs Management

| Command                     | Description                                             |
|-----------------------------|---------------------------------------------------------|
| `make logs`                 | Show logs for all services.                            |
| `make logs-base`            | Show logs for Traefik and Pihole.                      |
| `make logs-all-services`    | Show logs for all active services.                     |
| `make logs-service`         | Show logs for a specific service (`SERVICE=<service_name>`). |
| `make logs-traefik`         | Show logs for Traefik.                                  |
| `make logs-pihole`          | Show logs for Pihole.                                   |
| `make logs-pihole-dns`      | Show DNS logs for Pihole.                               |
| `make logs-traefik-access`  | Show Traefik access logs.                               |

---

### 📋 Service Interaction

| Command                      | Description                             |
|------------------------------|-----------------------------------------|
| `make shell-traefik`         | Open a shell in the Traefik container. |
| `make shell-pihole`          | Open a shell in the Pihole container.  |
| `make cmd-pihole-localdns`   | Update Pihole DNS entries.             |
| `make cmd-pihole-adlists`    | Add Pihole adlists.                    |
| `make cmd-pihole-adlists-clean`| Clean Pihole adlists.                |

---

### 📋 Utility Commands

| Command      | Description                                     |
|--------------|-------------------------------------------------|
| `make help`  | Display help information for all commands.      |
| `make list`  | List all active services configured in `.env`.  |



## License

This project is private and not licensed for public use. All rights reserved.

## References Block Lists:

[https://github.com/hagezi/dns-blocklists](https://github.com/hagezi/dns-blocklists)