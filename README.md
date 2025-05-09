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

| Service         | Image                                       | Purpose                                                                 |
|-----------------|---------------------------------------------|-------------------------------------------------------------------------|
| [**Traefik**](https://traefik.io/)           | `traefik:v3.3`                             | Reverse proxy, routing, and automatic SSL certificate management.       |
| [**Pihole**](https://pi-hole.net/)           | `pihole/pihole:latest`                     | DNS sinkhole for ads and tracking domains.                              |
| [**Navidrome**](https://www.navidrome.org/)  | `deluan/navidrome:latest`                  | Lightweight, web-based music server compatible with Subsonic clients.   |
| [**Jellyfin**](https://jellyfin.org/)        | `jellyfin/jellyfin:latest`                 | Media server for streaming movies, shows, and music.                    |
| [**Radarr**](https://radarr.video/)          | `lscr.io/linuxserver/radarr:latest`                | Movie collection manager with automated downloads and organization.     |
| [**Sonarr**](https://sonarr.tv/)             | `lscr.io/linuxserver/sonarr:latest`                | Series manager with support for episode tracking and automatic grabbing.|
| [**Jackett**](https://github.com/Jackett/Jackett) | `lscr.io/linuxserver/jackett:latest`         | Proxy indexer that translates queries for public/private torrent sites. |
| [**Flaresolverr**](https://github.com/FlareSolverr/FlareSolverr) | `ghcr.io/flaresolverr/flaresolverr:latest` | CAPTCHA-solving proxy for bypassing Cloudflare protection.              |
| [**Transmission**](https://transmissionbt.com/) | `lscr.io/linuxserver/transmission:4.0.5`       | Lightweight and efficient BitTorrent client with web UI.                |
| [**Homepage**](https://gethomepage.dev/)     | `ghcr.io/gethomepage/homepage:latest`      | Dashboard for all your self-hosted services.                            |
| [**Mealie**](https://docs.mealie.io/)        | `ghcr.io/mealie-recipes/mealie:latest`     | Self-hosted recipe manager and meal planner.                            |
| [**AdGuard**](https://adguard.com/)          | `adguard/adguardhome:latest`               | DNS-level ad and tracker blocking server.                               |
| [**n8n**](https://n8n.io/)                   | `n8nio/n8n:latest`                         | Workflow automation tool for connecting APIs and services.              |
| [**Dockerproxy**](https://github.com/Tecnativa/docker-socket-proxy) | `ghcr.io/tecnativa/docker-socket-proxy:latest` | Secure Docker socket proxy to expose selected Docker API endpoints. |
| [**Feishin**](https://github.com/jeffvli/feishin)          | `feishin/feishin:latest` (si existiera)    | Desktop music player frontend for Navidrome and Jellyfin.               |
| [**Bazarr**](https://www.bazarr.media/)      | `lscr.io/linuxserver/bazarr:latest`            | Companion app for subtitle management with Radarr and Sonarr.          |
| [**RDTClient**](https://github.com/rogerfar/rdt-client) | `rogerfar/rdtclient`         | Real-Debrid download manager with web interface.                        |

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

---

### ⚙️ Base

| Command                | Description                                       |
|------------------------|---------------------------------------------------|
| `make start`           | Up all services (Traefik, Pi-hole and active services) |
| `make stop`            | Stop all services (Traefik, Pi-hole and active services) |
| `make restart`         | Restart all services (Traefik, Pi-hole and active services) |
| `make start-all-services` | Up all active services                        |
| `make stop-all-services`  | Stop all active services                      |
| `make restart-services`   | Restart all active services                   |
| `make start-net-services` | Up all network services                       |
| `make stop-net-services`  | Stop all network services                     |
| `make restart-net-services` | Restart all network services               |
| `make list`            | List all active services                         |
| `make help`            | Show help for each of the Makefile recipes       |

---

### 🌐 Traefik

| Command               | Description                             |
|-----------------------|-----------------------------------------|
| `make traefik-start`  | Start Traefik service                   |
| `make traefik-stop`   | Stop Traefik service                    |
| `make traefik-restart`| Restart Traefik service                 |
| `make traefik-logs`   | View logs of Traefik                    |
| `make traefik-logs-access` | View Traefik access logs          |
| `make traefik-shell`  | Open a shell in the Traefik container   |
| `make traefik-upgrade`| Upgrade Traefik service                 |

---

### 📦 Mediastack

| Command                   | Description                           |
|---------------------------|---------------------------------------|
| `make mediastack-start`   | Start Mediastack services             |
| `make mediastack-stop`    | Stop Mediastack services              |
| `make mediastack-restart` | Restart Mediastack services           |
| `make mediastack-update`  | Pull latest images for Mediastack     |

---

### 📡 Pi-hole

| Command                        | Description                         |
|--------------------------------|-------------------------------------|
| `make pihole-start`            | Start Pi-hole service               |
| `make pihole-stop`             | Stop Pi-hole service                |
| `make pihole-restart`          | Restart Pi-hole service             |
| `make pihole-logs`             | View logs of Pi-hole                |
| `make pihole-shell`            | Open a shell in the Pi-hole container |
| `make pihole-logs-dns`         | View Pi-hole DNS logs               |
| `make pihole-logs-doh`         | View Pi-hole DoH logs               |
| `make pihole-cmd-localdns`     | Update local DNS records            |
| `make pihole-cmd-adlists`      | Update adlists                      |
| `make pihole-cmd-adlists-clean`| Disable adlists                     |
| `make pihole-cmd-flushdns`     | Flush DNS                           |

---

### 🎧 Navidrome

| Command                  | Description                         |
|--------------------------|-------------------------------------|
| `make navidrome-start`   | Start Navidrome service             |
| `make navidrome-stop`    | Stop Navidrome service              |
| `make navidrome-restart` | Restart Navidrome service           |
| `make navidrome-logs`    | View logs of Navidrome              |
| `make navidrome-shell`   | Open a shell in the Navidrome container |
| `make navidrome-upgrade` | Upgrade Navidrome service           |

---

### 📺 Jellyfin

| Command                     | Description                         |
|-----------------------------|-------------------------------------|
| `make jellyfin-start`       | Start Jellyfin service              |
| `make jellyfin-stop`        | Stop Jellyfin service               |
| `make jellyfin-restart`     | Restart Jellyfin service            |
| `make jellyfin-logs`        | View logs of Jellyfin               |
| `make jellyfin-shell`       | Open a shell in the Jellyfin container |
| `make jellyfin-cmd-checkhw` | Check hardware acceleration         |
| `make jellyfin-upgrade`     | Upgrade Jellyfin service            |

---

### 🏠 Homepage

| Command                  | Description                         |
|--------------------------|-------------------------------------|
| `make homepage-start`    | Start Homepage service              |
| `make homepage-stop`     | Stop Homepage service               |
| `make homepage-restart`  | Restart Homepage service            |
| `make homepage-logs`     | View logs of Homepage               |
| `make homepage-shell`    | Open a shell in the Homepage container |

---

### 🍲 Mealie

| Command                | Description                         |
|------------------------|-------------------------------------|
| `make mealie-start`    | Start Mealie service                |
| `make mealie-stop`     | Stop Mealie service                 |
| `make mealie-restart`  | Restart Mealie service              |
| `make mealie-logs`     | View logs of Mealie                 |
| `make mealie-shell`    | Open a shell in the Mealie container |
| `make mealie-upgrade`  | Upgrade Mealie service              |

---

### 🛡️ AdGuard

| Command                | Description                         |
|------------------------|-------------------------------------|
| `make adguard-start`   | Start AdGuard service               |
| `make adguard-stop`    | Stop AdGuard service                |
| `make adguard-restart` | Restart AdGuard service             |
| `make adguard-logs`    | View logs of AdGuard                |
| `make adguard-shell`   | Open a shell in the AdGuard container |
| `make adguard-upgrade` | Upgrade AdGuard service             |

---

### 🔁 N8N

| Command              | Description                         |
|----------------------|-------------------------------------|
| `make n8n-start`     | Start N8N service                   |
| `make n8n-stop`      | Stop N8N service                    |
| `make n8n-restart`   | Restart N8N service                 |
| `make n8n-logs`      | View logs of N8N                    |
| `make n8n-shell`     | Open a shell in the N8N container   |
| `make n8n-upgrade`   | Upgrade N8N service                 |

---

### 🌐 Dockerproxy

| Command                   | Description                         |
|---------------------------|-------------------------------------|
| `make dockerproxy-start`  | Start Dockerproxy service           |
| `make dockerproxy-stop`   | Stop Dockerproxy service            |
| `make dockerproxy-restart`| Restart Dockerproxy service         |
| `make dockerproxy-logs`   | View logs of Dockerproxy            |
| `make dockerproxy-shell`  | Open a shell in the Dockerproxy container |

---

### 🎶 Feishin

| Command              | Description                         |
|----------------------|-------------------------------------|
| `make feishin-start` | Start Feishin service               |
| `make feishin-stop`  | Stop Feishin service                |
| `make feishin-restart`| Restart Feishin service            |
| `make feishin-logs`  | View logs of Feishin                |
| `make feishin-shell` | Open a shell in the Feishin container |

---

### 🎬 Radarr

| Command              | Description                         |
|----------------------|-------------------------------------|
| `make radarr-start`  | Start Radarr service                |
| `make radarr-stop`   | Stop Radarr service                 |
| `make radarr-restart`| Restart Radarr service              |
| `make radarr-logs`   | View logs of Radarr                 |
| `make radarr-shell`  | Open a shell in the Radarr container |

---

### 📺 Sonarr

| Command              | Description                         |
|----------------------|-------------------------------------|
| `make sonarr-start`  | Start Sonarr service                |
| `make sonarr-stop`   | Stop Sonarr service                 |
| `make sonarr-restart`| Restart Sonarr service              |
| `make sonarr-logs`   | View logs of Sonarr                 |
| `make sonarr-shell`  | Open a shell in the Sonarr container |

---

### 🧲 Jackett

| Command               | Description                        |
|-----------------------|------------------------------------|
| `make jackett-start`  | Start Jackett service              |
| `make jackett-stop`   | Stop Jackett service               |
| `make jackett-restart`| Restart Jackett service            |
| `make jackett-logs`   | View logs of Jackett               |
| `make jackett-shell`  | Open a shell in the Jackett container |

---

### 🔥 Flaresolverr

| Command                    | Description                         |
|----------------------------|-------------------------------------|
| `make flaresolverr-start`  | Start Flaresolverr service          |
| `make flaresolverr-stop`   | Stop Flaresolverr service           |
| `make flaresolverr-restart`| Restart Flaresolverr service        |
| `make flaresolverr-logs`   | View logs of Flaresolverr           |
| `make flaresolverr-shell`  | Open a shell in the Flaresolverr container |

---

### ⬇️ Transmission

| Command                    | Description                         |
|----------------------------|-------------------------------------|
| `make transmission-start`  | Start Transmission service          |
| `make transmission-stop`   | Stop Transmission service           |
| `make transmission-restart`| Restart Transmission service        |
| `make transmission-logs`   | View logs of Transmission           |
| `make transmission-shell`  | Open a shell in the Transmission container |

---

### 📃 Bazarr

| Command              | Description                         |
|----------------------|-------------------------------------|
| `make bazarr-start`  | Start Bazarr service                |
| `make bazarr-stop`   | Stop Bazarr service                 |
| `make bazarr-restart`| Restart Bazarr service              |
| `make bazarr-logs`   | View logs of Bazarr                 |
| `make bazarr-shell`  | Open a shell in the Bazarr container |

---

### ☁️ RDTClient

| Command                 | Description                         |
|-------------------------|-------------------------------------|
| `make rdtclient-start`  | Start RDTClient service             |
| `make rdtclient-stop`   | Stop RDTClient service              |
| `make rdtclient-restart`| Restart RDTClient service           |
| `make rdtclient-logs`   | View logs of RDTClient              |
| `make rdtclient-shell`  | Open a shell in the RDTClient container |


## License

This project is licensed under the MIT License.  
It is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and noninfringement.  
The authors are not responsible for any misuse of the tools orchestrated by this project. Use it at your own risk.

## FAQ

### Q: I'm having trouble generating the Let's Encrypt certificate.  🔐
**A:** The issue might be caused by the default configuration enabling the Cloudflared certificate. To resolve the problem, disable the Cloudflared certificate in your configuration `tls.yml` so that the Let's Encrypt certificate can be generated successfully.


## Resources:

### Block Lists:

- [https://github.com/hagezi/dns-blocklists](https://github.com/hagezi/dns-blocklists)
- [https://doc.traefik.io/traefik/reference/dynamic-configuration/docker/](https://doc.traefik.io/traefik/reference/dynamic-configuration/docker/)

### Homepage
- [https://github.com/homarr-labs/dashboard-icons/tree/main/svg](https://github.com/homarr-labs/dashboard-icons/tree/main/svg)
