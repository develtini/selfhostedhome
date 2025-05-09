SERVICES_DIR=./services
NET_DIR=./net
ACTIVE_SERVICES=$(shell grep ^ACTIVE_SERVICES .env | cut -d '=' -f2 | sed 's/,$$//' | sed 's/,/ /g')
NET_SERVICES=$(shell grep ^ACTIVE_NET_SERVICES .env | cut -d '=' -f2 | sed 's/,$$//' | sed 's/,/ /g')

.PHONY: \
	help list \
	start start-all-services start-net-services \
	stop stop-all-services stop-net-services \
	restart restart-services restart-net-services \
	traefik-start traefik-stop traefik-restart traefik-logs traefik-shell traefik-logs-access \
	navidrome-start navidrome-stop navidrome-restart navidrome-logs navidrome-shell \
	jellyfin-start jellyfin-stop jellyfin-restart jellyfin-logs jellyfin-shell jellyfin-cmd-checkhw \
	homepage-start homepage-stop homepage-restart homepage-logs homepage-shell \
	mealie-start mealie-stop mealie-restart mealie-logs mealie-shell \
	adguard-start adguard-stop adguard-restart adguard-logs adguard-shell \
	n8n-start n8n-stop n8n-restart n8n-logs n8n-shell \
	dockerproxy-start dockerproxy-stop dockerproxy-restart dockerproxy-logs dockerproxy-shell \
	feishin-start feishin-stop feishin-restart feishin-logs feishin-shell \
	pihole-start pihole-stop pihole-restart pihole-logs pihole-shell pihole-logs-dns pihole-logs-doh pihole-cmd-localdns pihole-cmd-adlists pihole-cmd-adlists-clean pihole-cmd-flushdns \
	radarr-start radarr-stop radarr-restart radarr-logs radarr-shell \
	sonarr-start sonarr-stop sonarr-restart sonarr-logs sonarr-shell \
	jackett-start jackett-stop jackett-restart jackett-logs jackett-shell \
	flaresolverr-start flaresolverr-stop flaresolverr-restart flaresolverr-logs flaresolverr-shell \
	transmission-start transmission-stop transmission-restart transmission-logs transmission-shell \
	bazarr-start bazarr-stop bazarr-restart bazarr-logs bazarr-shell \
	rdtclient-start rdtclient-stop rdtclient-restart rdtclient-logs rdtclient-shell \
	mediastack-start mediastack-stop mediastack-restart mediastack-update \

help: ## Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done | column -t -c 2 -s ':#'

list: ## List all active services
	@echo "Active services configured in .env: $(ACTIVE_SERVICES)"
	@echo "Active network services configured in .env: $(NET_SERVICES)"


## Base Commands ##


start: ## Up all services (Traefik, Pihole and active services)
	$(MAKE) traefik-start
	${MAKE} start-net-services
	$(MAKE) start-all-services

start-all-services: ## Up all active services
	@echo "Starting active services..."
	@for SERVICE in $(ACTIVE_SERVICES); do \
		echo "Starting $$SERVICE..."; \
		docker compose --env-file .env --env-file $(SERVICES_DIR)/$$SERVICE/.env -f docker-compose.yaml -f $(SERVICES_DIR)/$$SERVICE/docker-compose.$$SERVICE.yaml up -d; \
	done
	@echo "All active services started successfully."

start-net-services: ## Up all network services
	@echo "Starting network services..."
	@for SERVICE in $(NET_SERVICES); do \
		echo "Starting $$SERVICE..."; \
		docker compose --env-file .env --env-file $(NET_DIR)/$$SERVICE/.env -f docker-compose.yaml -f $(NET_DIR)/$$SERVICE/docker-compose.$$SERVICE.yaml up -d; \
	done
	@echo "All network services started successfully."


start-mediastack: ## Up mediastack services
	@echo "Starting mediastack services..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml up -d
	@echo "Mediastack services started successfully."

stop: ## Stop all services (Traefik, Pihole and active services)
	$(MAKE) stop-all-services
	$(MAKE) stop-net-services
	$(MAKE) traefik-stop

stop-net-services: ## Stop all network services
	@echo "Stopping network services..."
	@for SERVICE in $(NET_SERVICES); do \
		echo "Stopping $$SERVICE..."; \
		docker compose --env-file .env --env-file $(NET_DIR)/$$SERVICE/.env -f docker-compose.yaml -f $(NET_DIR)/$$SERVICE/docker-compose.$$SERVICE.yaml down; \
	done
	@echo "All network services stopped successfully."

stop-all-services: ## Stop all active services
	@echo "Stopping all active services..."
	@for SERVICE in $(ACTIVE_SERVICES); do \
		echo "Stopping $$SERVICE..."; \
		docker compose --env-file .env --env-file $(SERVICES_DIR)/$$SERVICE/.env -f docker-compose.yaml -f $(SERVICES_DIR)/$$SERVICE/docker-compose.$$SERVICE.yaml down; \
	done
	@echo "All active services stopped successfully."

stop-mediastack: ## Stop mediastack services
	@echo "Stopping mediastack services..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml down
	@echo "Mediastack services stopped successfully."


restart: ## Restart all services (Traefik, Pihole and active services)
	@echo "Restarting Traefik and services..."
	$(MAKE) stop
	$(MAKE) start

restart-services: ## Restart all active services
	@echo "Restarting all active services..."
	@for SERVICE in $(ACTIVE_SERVICES); do \
		echo "Restarting $$SERVICE..."; \
		docker compose --env-file .env --env-file $(SERVICES_DIR)/$$SERVICE/.env -f docker-compose.yaml -f $(SERVICES_DIR)/$$SERVICE/docker-compose.$$SERVICE.yaml restart; \
	done
	@echo "All active services restarted successfully."

restart-net-services: ## Restart all network services
	@echo "Restarting all network services..."
	@for SERVICE in $(NET_SERVICES); do \
		echo "Restarting $$SERVICE..."; \
		docker compose --env-file .env --env-file $(NET_DIR)/$$SERVICE/.env -f docker-compose.yaml -f $(NET_DIR)/$$SERVICE/docker-compose.$$SERVICE.yaml restart; \
	done
	@echo "All network services restarted successfully."
	

## Mediastack Commands ##

mediastack-stop: ## Stop mediastack services
	@echo "Stopping mediastack services..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml stop
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml rm -f
	@echo "Mediastack services stopped successfully."

mediastack-start: ## Start mediastack services
	@echo "Starting mediastack services..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml up -d
	@echo "Mediastack services started successfully."

mediastack-restart: ## Restart mediastack services
	@echo "Restarting mediastack services..."
	$(MAKE) mediastack-stop
	$(MAKE) mediastack-start
	@echo "Mediastack services restarted successfully."

mediastack-update: ## Pull latest images for mediastack services
	@echo "Pulling mediastack images..."
	docker compose --env-file .env --env-file ./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml pull
	@echo "Stopping mediastack services..."
	$(MAKE) mediastack-stop
	@echo "Starting mediastack services..."
	$(MAKE) mediastack-start


## Traefik Commands ##


traefik-stop: ## Stop Traefik service
	@echo "Stopping Traefik service..."
	docker compose --env-file .env --env-file ./traefik/.env -f docker-compose.yaml -f ./traefik/docker-compose.traefik.yaml stop traefik
	docker compose --env-file .env --env-file ./traefik/.env -f docker-compose.yaml -f ./traefik/docker-compose.traefik.yaml rm -f traefik
	@echo "Traefik service stopped successfully."

traefik-start: ## Start Traefik service
	@echo "Starting Traefik service..."
	docker compose --env-file .env --env-file ./traefik/.env -f docker-compose.yaml -f ./traefik/docker-compose.traefik.yaml up -d
	@echo "Traefik service started successfully."

traefik-restart: ## Restart Traefik service
	@echo "Restarting Traefik service..."
	$(MAKE) traefik-stop
	$(MAKE) traefik-start
	@echo "Traefik service restarted successfully."

traefik-logs: ## View logs of Traefik
	@echo "Showing logs for Traefik..."
	docker compose --env-file .env --env-file=./traefik/.env -f docker-compose.yaml -f ./traefik/docker-compose.traefik.yaml logs -f

traefik-shell: ## Open a shell in the Traefik container
	docker compose --env-file .env --env-file ./traefik/.env -f docker-compose.yaml -f ./traefik/docker-compose.traefik.yaml exec -it traefik /bin/sh

traefik-logs-access: ## View Traefik access logs (tail -f /var/log/nginx/access.log)
	@echo "Showing Traefik access logs..."
	docker compose --env-file .env --env-file=./traefik/.env -f docker-compose.yaml -f ./traefik/docker-compose.traefik.yaml exec -it traefik tail -f /var/log/traefik/access.log

traefik-upgrade: ## Upgrade Traefik service
	@echo "Upgrading Traefik service..."
	docker compose --env-file .env --env-file ./traefik/.env -f docker-compose.yaml -f ./traefik/docker-compose.traefik.yaml pull
	@echo "Traefik service upgraded successfully."
	@echo "Restarting Traefik service..."
	$(MAKE) traefik-restart
	@echo "Traefik service restarted successfully."

## Navidrome Commands ##

navidrome-stop: ## Stop Navidrome service
	@echo "Stopping Navidrome service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/navidrome/.env -f docker-compose.yaml -f $(SERVICES_DIR)/navidrome/docker-compose.navidrome.yaml stop navidrome
	docker compose --env-file .env --env-file $(SERVICES_DIR)/navidrome/.env -f docker-compose.yaml -f $(SERVICES_DIR)/navidrome/docker-compose.navidrome.yaml rm -f navidrome
	@echo "Navidrome service stopped successfully."

navidrome-start: ## Start Navidrome service
	@echo "Starting Navidrome service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/navidrome/.env -f docker-compose.yaml -f $(SERVICES_DIR)/navidrome/docker-compose.navidrome.yaml up -d
	@echo "Navidrome service started successfully."

navidrome-restart: ## Restart Navidrome service
	@echo "Restarting Navidrome service..."
	$(MAKE) navidrome-stop
	$(MAKE) navidrome-start
	@echo "Navidrome service restarted successfully."

navidrome-logs: ## View logs of Navidrome
	@echo "Showing logs for Navidrome..."
	docker compose --env-file .env --env-file=./services/navidrome/.env -f docker-compose.yaml -f ./services/navidrome/docker-compose.navidrome.yaml logs -f

navidrome-shell: ## Open a shell in the Navidrome container
	docker compose --env-file .env --env-file ./services/navidrome/.env -f docker-compose.yaml -f ./services/navidrome/docker-compose.navidrome.yaml exec -it navidrome /bin/sh

navidrome-upgrade: ## Upgrade Navidrome service
	@echo "Upgrading Navidrome service..."
	docker compose --env-file .env --env-file ./services/navidrome/.env -f docker-compose.yaml -f ./services/navidrome/docker-compose.navidrome.yaml pull
	@echo "Navidrome service upgraded successfully."
	@echo "Restarting Navidrome service..."
	$(MAKE) navidrome-restart
	@echo "Navidrome service restarted successfully."

## Jellyfin Commands ##


jellyfin-stop: ## Stop Jellyfin service
	@echo "Stopping Jellyfin service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/jellyfin/.env -f docker-compose.yaml -f $(SERVICES_DIR)/jellyfin/docker-compose.jellyfin.yaml stop jellyfin
	docker compose --env-file .env --env-file $(SERVICES_DIR)/jellyfin/.env -f docker-compose.yaml -f $(SERVICES_DIR)/jellyfin/docker-compose.jellyfin.yaml rm -f jellyfin
	@echo "Jellyfin service stopped successfully."

jellyfin-start: ## Start Jellyfin service
	@echo "Starting Jellyfin service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/jellyfin/.env -f docker-compose.yaml -f $(SERVICES_DIR)/jellyfin/docker-compose.jellyfin.yaml up -d
	@echo "Jellyfin service started successfully."

jellyfin-restart: ## Restart Jellyfin service
	@echo "Restarting Jellyfin service..."
	$(MAKE) jellyfin-stop
	$(MAKE) jellyfin-start
	@echo "Jellyfin service restarted successfully."

jellyfin-logs: ## View logs of Jellyfin
	@echo "Showing logs for Jellyfin..."
	docker compose --env-file .env --env-file=./services/jellyfin/.env -f docker-compose.yaml -f ./services/jellyfin/docker-compose.jellyfin.yaml logs -f

jellyfin-shell: ## Open a shell in the Jellyfin container
	docker compose --env-file .env --env-file ./services/jellyfin/.env -f docker-compose.yaml -f ./services/jellyfin/docker-compose.jellyfin.yaml exec -it jellyfin /bin/bash

jellyfin-cmd-checkhw: ## Check hardware acceleration
	@echo "Checking QSV and VA-API for Jellyfin..."
	docker compose --env-file .env --env-file ./services/jellyfin/.env -f docker-compose.yaml -f ./services/jellyfin/docker-compose.jellyfin.yaml exec -it jellyfin /bin/bash -c "/usr/lib/jellyfin-ffmpeg/vainfo"
	@echo "Checking OpenCL for Jellyfin..."
	docker compose --env-file .env --env-file ./services/jellyfin/.env -f docker-compose.yaml -f ./services/jellyfin/docker-compose.jellyfin.yaml exec -it jellyfin /bin/bash -c "/usr/lib/jellyfin-ffmpeg/ffmpeg -v verbose -init_hw_device vaapi=va -init_hw_device opencl@va"

jellyfin-upgrade: ## Upgrade Jellyfin service
	@echo "Upgrading Jellyfin service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/jellyfin/.env -f docker-compose.yaml -f $(SERVICES_DIR)/jellyfin/docker-compose.jellyfin.yaml pull
	@echo "Jellyfin service upgraded successfully."
	@echo "Restarting Jellyfin service..."
	$(MAKE) jellyfin-restart
	@echo "Jellyfin service restarted successfully."

## Homepage Commands ##


homepage-stop: ## Stop Homepage service
	@echo "Stopping Homepage service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/homepage/.env -f docker-compose.yaml -f $(SERVICES_DIR)/homepage/docker-compose.homepage.yaml stop homepage
	docker compose --env-file .env --env-file $(SERVICES_DIR)/homepage/.env -f docker-compose.yaml -f $(SERVICES_DIR)/homepage/docker-compose.homepage.yaml rm -f homepage
	@echo "Homepage service stopped successfully."

homepage-start: ## Start Homepage service
	@echo "Starting Homepage service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/homepage/.env -f docker-compose.yaml -f $(SERVICES_DIR)/homepage/docker-compose.homepage.yaml up -d
	@echo "Homepage service started successfully."

homepage-restart: ## Restart Homepage service
	@echo "Restarting Homepage service..."
	$(MAKE) homepage-stop
	$(MAKE) homepage-start
	@echo "Homepage service restarted successfully."

homepage-logs: ## View logs of Homepage
	@echo "Showing logs for Homepage..."
	docker compose --env-file .env --env-file=./services/homepage/.env -f docker-compose.yaml -f ./services/homepage/docker-compose.homepage.yaml logs -f

homepage-shell: ## Open a shell in the Homepage container
	docker compose --env-file .env --env-file ./services/homepage/.env -f docker-compose.yaml -f ./services/homepage/docker-compose.homepage.yaml exec -it homepage /bin/sh


## Mealie Commands ##


mealie-stop: ## Stop Mealie service
	@echo "Stopping Mealie service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mealie/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mealie/docker-compose.mealie.yaml stop mealie
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mealie/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mealie/docker-compose.mealie.yaml rm -f mealie
	@echo "Mealie service stopped successfully."

mealie-start: ## Start Mealie service
	@echo "Starting Mealie service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mealie/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mealie/docker-compose.mealie.yaml up -d
	@echo "Mealie service started successfully."

mealie-restart: ## Restart Mealie service
	@echo "Restarting Mealie service..."
	$(MAKE) mealie-stop
	$(MAKE) mealie-start
	@echo "Mealie service restarted successfully."

mealie-logs: ## View logs of Mealie
	@echo "Showing logs for Mealie..."
	docker compose --env-file .env --env-file=./services/mealie/.env -f docker-compose.yaml -f ./services/mealie/docker-compose.mealie.yaml logs -f

mealie-shell: ## Open a shell in the Mealie container
	docker compose --env-file .env --env-file ./services/mealie/.env -f docker-compose.yaml -f ./services/mealie/docker-compose.mealie.yaml exec -it mealie /bin/bash

mealie-upgrade: ## Upgrade Mealie service
	@echo "Upgrading Mealie service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mealie/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mealie/docker-compose.mealie.yaml pull
	@echo "Mealie service upgraded successfully."
	@echo "Restarting Mealie service..."
	$(MAKE) mealie-restart
	@echo "Mealie service restarted successfully."

## AdGuard Commands ##


adguard-start: ## Start AdGuard service
	@echo "Starting AdGuard service..."
	docker compose --env-file .env --env-file $(NET_DIR)/adguard/.env -f docker-compose.yaml -f $(NET_DIR)/adguard/docker-compose.adguard.yaml up -d
	@echo "AdGuard service started successfully."

adguard-stop: ## Stop AdGuard service
	@echo "Stopping AdGuard service..."
	docker compose --env-file .env --env-file $(NET_DIR)/adguard/.env -f docker-compose.yaml -f $(NET_DIR)/adguard/docker-compose.adguard.yaml stop adguard
	docker compose --env-file .env --env-file $(NET_DIR)/adguard/.env -f docker-compose.yaml -f $(NET_DIR)/adguard/docker-compose.adguard.yaml rm -f adguard
	@echo "AdGuard service stopped successfully."

adguard-restart: ## Restart AdGuard service
	@echo "Restarting AdGuard service..."
	$(MAKE) adguard-stop
	$(MAKE) adguard-start
	@echo "AdGuard service restarted successfully."

adguard-logs: ## View logs of AdGuard
	@echo "Showing logs for AdGuard..."
	docker compose --env-file .env --env-file $(NET_DIR)/adguard/.env -f docker-compose.yaml -f $(NET_DIR)/adguard/docker-compose.adguard.yaml logs -f

adguard-shell: ## Open a shell in the AdGuard container
	docker compose --env-file .env --env-file $(NET_DIR)/adguard/.env -f docker-compose.yaml -f $(NET_DIR)/adguard/docker-compose.adguard.yaml exec -it adguard /bin/sh

adguard-upgrade: ## Upgrade AdGuard service
	@echo "Upgrading AdGuard service..."
	docker compose --env-file .env --env-file $(NET_DIR)/adguard/.env -f docker-compose.yaml -f $(NET_DIR)/adguard/docker-compose.adguard.yaml pull
	@echo "AdGuard service upgraded successfully."
	@echo "Restarting AdGuard service..."
	$(MAKE) adguard-restart
	@echo "AdGuard service restarted successfully."

## N8N Commands ##


n8n-stop: ## Stop N8N service
	@echo "Stopping N8N service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/n8n/.env -f docker-compose.yaml -f $(SERVICES_DIR)/n8n/docker-compose.n8n.yaml stop n8n
	docker compose --env-file .env --env-file $(SERVICES_DIR)/n8n/.env -f docker-compose.yaml -f $(SERVICES_DIR)/n8n/docker-compose.n8n.yaml rm -f n8n
	@echo "N8N service stopped successfully."

n8n-start: ## Start N8N service
	@echo "Starting N8N service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/n8n/.env -f docker-compose.yaml -f $(SERVICES_DIR)/n8n/docker-compose.n8n.yaml up -d
	@echo "N8N service started successfully."

n8n-restart: ## Restart N8N service
	@echo "Restarting N8N service..."
	$(MAKE) n8n-stop
	$(MAKE) n8n-start
	@echo "N8N service restarted successfully."

n8n-logs: ## View logs of N8N
	@echo "Showing logs for N8N..."
	docker compose --env-file .env --env-file=./services/n8n/.env -f docker-compose.yaml -f ./services/n8n/docker-compose.n8n.yaml logs -f

n8n-shell: ## Open a shell in the N8N container
	docker compose --env-file .env --env-file ./services/n8n/.env -f docker-compose.yaml -f ./services/n8n/docker-compose.n8n.yaml exec -it n8n /bin/sh

n8n-upgrade: ## Upgrade N8N service
	@echo "Upgrading N8N service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/n8n/.env -f docker-compose.yaml -f $(SERVICES_DIR)/n8n/docker-compose.n8n.yaml pull
	@echo "N8N service upgraded successfully."
	@echo "Restarting N8N service..."
	$(MAKE) n8n-restart
	@echo "N8N service restarted successfully."


## Dockerproxy Commands ##


dockerproxy-stop: ## Stop Dockerproxy service
	@echo "Stopping Dockerproxy service..."
	docker compose --env-file .env --env-file $(NET_DIR)/dockerproxy/.env -f docker-compose.yaml -f $(NET_DIR)/dockerproxy/docker-compose.dockerproxy.yaml stop dockerproxy
	docker compose --env-file .env --env-file $(NET_DIR)/dockerproxy/.env -f docker-compose.yaml -f $(NET_DIR)/dockerproxy/docker-compose.dockerproxy.yaml rm -f dockerproxy
	@echo "Dockerproxy service stopped successfully."

dockerproxy-start: ## Start Dockerproxy service
	@echo "Starting Dockerproxy service..."
	docker compose --env-file .env --env-file $(NET_DIR)/dockerproxy/.env -f docker-compose.yaml -f $(NET_DIR)/dockerproxy/docker-compose.dockerproxy.yaml up -d
	@echo "Dockerproxy service started successfully."

dockerproxy-restart: ## Restart Dockerproxy service
	@echo "Restarting Dockerproxy service..."
	$(MAKE) dockerproxy-stop
	$(MAKE) dockerproxy-start
	@echo "Dockerproxy service restarted successfully."

dockerproxy-logs: ## View logs of Dockerproxy
	@echo "Showing logs for Dockerproxy..."
	docker compose --env-file .env --env-file=./net/dockerproxy/.env -f docker-compose.yaml -f ./net/dockerproxy/docker-compose.dockerproxy.yaml logs -f

dockerproxy-shell: ## Open a shell in the Dockerproxy container
	docker compose --env-file .env --env-file ./net/dockerproxy/.env -f docker-compose.yaml -f ./net/dockerproxy/docker-compose.dockerproxy.yaml exec -it dockerproxy /bin/sh

## Feishin Commands ##


feishin-stop: ## Stop Feishin service
	@echo "Stopping Feishin service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/feishin/.env -f docker-compose.yaml -f $(SERVICES_DIR)/feishin/docker-compose.feishin.yaml stop feishin
	docker compose --env-file .env --env-file $(SERVICES_DIR)/feishin/.env -f docker-compose.yaml -f $(SERVICES_DIR)/feishin/docker-compose.feishin.yaml rm -f feishin
	@echo "Feishin service stopped successfully."

feishin-start: ## Start Feishin service
	@echo "Starting Feishin service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/feishin/.env -f docker-compose.yaml -f $(SERVICES_DIR)/feishin/docker-compose.feishin.yaml up -d
	@echo "Feishin service started successfully."

feishin-restart: ## Restart Feishin service
	@echo "Restarting Feishin service..."
	$(MAKE) feishin-stop
	$(MAKE) feishin-start
	@echo "Feishin service restarted successfully."

feishin-logs: ## View logs of Feishin
	@echo "Showing logs for Feishin..."
	docker compose --env-file .env --env-file=./services/feishin/.env -f docker-compose.yaml -f ./services/feishin/docker-compose.feishin.yaml logs -f

feishin-shell: ## Open a shell in the Feishin container
	docker compose --env-file .env --env-file ./services/feishin/.env -f docker-compose.yaml -f ./services/feishin/docker-compose.feishin.yaml exec -it feishin /bin/sh


## Pihole Commands ##


pihole-stop: ## Stop Pihole service
	@echo "Stopping Pihole service..."
	docker compose --env-file .env --env-file $(NET_DIR)/pihole/.env -f docker-compose.yaml -f $(NET_DIR)/pihole/docker-compose.pihole.yaml stop pihole
	docker compose --env-file .env --env-file $(NET_DIR)/pihole/.env -f docker-compose.yaml -f $(NET_DIR)/pihole/docker-compose.pihole.yaml rm -f pihole
	@echo "Pihole service stopped successfully."

pihole-start: ## Start Pihole service
	@echo "Starting Pihole service..."
	docker compose --env-file .env --env-file $(NET_DIR)/pihole/.env -f docker-compose.yaml -f $(NET_DIR)/pihole/docker-compose.pihole.yaml up -d
	@echo "Pihole service started successfully."

pihole-restart: ## Restart Pihole service
	@echo "Restarting Pihole service..."
	$(MAKE) pihole-stop
	$(MAKE) pihole-start
	@echo "Pihole service restarted successfully."

pihole-logs: ## View logs of Pihole
	@echo "Showing logs for Pihole..."
	docker compose --env-file .env --env-file=./net/pihole/.env -f docker-compose.yaml -f ./net/pihole/docker-compose.pihole.yaml logs -f

pihole-shell: ## Open a shell in the Pihole container
	docker compose --env-file .env --env-file ./net/pihole/.env -f docker-compose.yaml -f ./net/pihole/docker-compose.pihole.yaml exec -it pihole /bin/bash

pihole-logs-dns: ## View Pihole DNS logs (tail -f /var/log/pihole/pihole.log)
	@echo "Showing Pihole DNS logs..."
	docker compose --env-file .env --env-file ./net/pihole/.env -f docker-compose.yaml -f ./net/pihole/docker-compose.pihole.yaml exec -it pihole tail -f /var/log/pihole/pihole.log

pihole-logs-doh: ## View Pihole DNS logs (tail -f /var/log/pihole/pihole.log)
	@echo "Showing Pihole DNS logs..."
	docker compose --env-file .env --env-file ./net/pihole/.env -f docker-compose.yaml -f ./net/pihole/docker-compose.pihole.yaml exec -it pihole tail -f /var/log/dnsdist.log

pihole-cmd-localdns: ## Update local DNS records
	docker compose --env-file .env --env-file ./net/pihole/.env -f docker-compose.yaml -f ./net/pihole/docker-compose.pihole.yaml exec -u root pihole sh -c "/bin/sh /etc/custom.d/01-static-entries/update-static-records.sh"

pihole-cmd-adlists: ## Update adlists
	docker compose --env-file .env --env-file ./net/pihole/.env -f docker-compose.yaml -f ./net/pihole/docker-compose.pihole.yaml exec -u root pihole sh -c "/bin/sh /etc/custom.d/02-adlists/add-adlists.sh"

pihole-cmd-adlists-clean: ## Disable adlists
	docker compose --env-file .env --env-file ./net/pihole/.env -f docker-compose.yaml -f ./net/pihole/docker-compose.pihole.yaml exec -u root pihole sh -c "/bin/sh /etc/custom.d/02-adlists/clean-adlists.sh"

pihole-cmd-flushdns: ## Flush dns
	docker compose --env-file .env --env-file ./net/pihole/.env -f docker-compose.yaml -f ./net/pihole/docker-compose.pihole.yaml exec -u root pihole sh -c ""


## Radarr Commands ##


radarr-stop: ## Stop Radarr service
	@echo "Stopping Radarr service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml stop radarr
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml rm -f radarr
	@echo "Radarr service stopped successfully."

radarr-start: ## Start Radarr service
	@echo "Starting Radarr service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml up radarr -d
	@echo "Radarr service started successfully."

radarr-restart: ## Restart Radarr service
	@echo "Restarting Radarr service..."
	$(MAKE) radarr-stop
	$(MAKE) radarr-start
	@echo "Radarr service restarted successfully."

radarr-logs: ## View logs of Radarr
	@echo "Showing logs for Radarr..."
	docker compose --env-file .env --env-file=./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml logs -f radarr

radarr-shell: ## Open a shell in the Radarr container
	docker compose --env-file .env --env-file ./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml exec -it radarr /bin/bash


## Sonarr Commands ##


sonarr-stop: ## Stop Sonarr service
	@echo "Stopping Sonarr service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml stop sonarr
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml rm -f sonarr
	@echo "Sonarr service stopped successfully."	

sonarr-start: ## Start Sonarr service
	@echo "Starting Sonarr service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml up sonarr -d
	@echo "Sonarr service started successfully."

sonarr-restart: ## Restart Sonarr service
	@echo "Restarting Sonarr service..."
	$(MAKE) sonarr-stop
	$(MAKE) sonarr-start
	@echo "Sonarr service restarted successfully."

sonarr-logs: ## View logs of Sonarr
	@echo "Showing logs for Sonarr..."
	docker compose --env-file .env --env-file=./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml logs -f sonarr

sonarr-shell: ## Open a shell in the Sonarr container
	docker compose --env-file .env --env-file ./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml exec -it sonarr /bin/bash

## Jackett Commands ##

jackett-stop: ## Stop Jackett service
	@echo "Stopping Jackett service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml stop jackett
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml rm -f jackett
	@echo "Jackett service stopped successfully."

jackett-start: ## Start Jackett service
	@echo "Starting Jackett service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml up jackett -d
	@echo "Jackett service started successfully."

jackett-restart: ## Restart Jackett service
	@echo "Restarting Jackett service..."
	$(MAKE) jackett-stop
	$(MAKE) jackett-start
	@echo "Jackett service restarted successfully."

jackett-logs: ## View logs of Jackett
	@echo "Showing logs for Jackett..."
	docker compose --env-file .env --env-file=./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml logs -f jackett

jackett-shell: ## Open a shell in the Jackett container
	docker compose --env-file .env --env-file ./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml exec -it jackett /bin/bash

## Flaresolverr Commands ##

flaresolverr-stop: ## Stop Flaresolverr service
	@echo "Stopping Flaresolverr service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml stop flaresolverr
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml rm -f flaresolverr
	@echo "Flaresolverr service stopped successfully."

flaresolverr-start: ## Start Flaresolverr service
	@echo "Starting Flaresolverr service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml up flaresolverr -d
	@echo "Flaresolverr service started successfully."

flaresolverr-restart: ## Restart Flaresolverr service
	@echo "Restarting Flaresolverr service..."
	$(MAKE) flaresolverr-stop
	$(MAKE) flaresolverr-start
	@echo "Flaresolverr service restarted successfully."

flaresolverr-logs: ## View logs of Flaresolverr
	@echo "Showing logs for Flaresolverr..."
	docker compose --env-file .env --env-file=./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml logs -f flaresolverr

flaresolverr-shell: ## Open a shell in the Flaresolverr container
	docker compose --env-file .env --env-file ./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml exec -it flaresolverr /bin/bash

## Transmission Commands ##

transmission-stop: ## Stop Transmission service
	@echo "Stopping Transmission service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml stop transmission
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml rm -f transmission
	@echo "Transmission service stopped successfully."

transmission-start: ## Start Transmission service
	@echo "Starting Transmission service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml up transmission -d
	@echo "Transmission service started successfully."

transmission-restart: ## Restart Transmission service
	@echo "Restarting Transmission service..."
	$(MAKE) transmission-stop
	$(MAKE) transmission-start
	@echo "Transmission service restarted successfully."

transmission-logs: ## View logs of Transmission
	@echo "Showing logs for Transmission..."
	docker compose --env-file .env --env-file=./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml logs

transmission-shell: ## Open a shell in the Transmission container
	docker compose --env-file .env --env-file ./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml exec -it transmission /bin/bash

## Bazarr Commands ##

bazarr-stop: ## Stop Bazarr service
	@echo "Stopping Bazarr service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml stop bazarr
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml rm -f bazarr
	@echo "Bazarr service stopped successfully."

bazarr-start: ## Start Bazarr service
	@echo "Starting Bazarr service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml up bazarr -d
	@echo "Bazarr service started successfully."

bazarr-restart: ## Restart Bazarr service
	@echo "Restarting Bazarr service..."
	$(MAKE) bazarr-stop
	$(MAKE) bazarr-start
	@echo "Bazarr service restarted successfully."

bazarr-logs: ## View logs of Bazarr
	@echo "Showing logs for Bazarr..."
	docker compose --env-file .env --env-file=./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml logs -f bazarr

bazarr-shell: ## Open a shell in the Bazarr container
	docker compose --env-file .env --env-file ./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml exec -it bazarr /bin/bash

## RDTClient Commands ##

rdtclient-stop: ## Stop RDTClient service
	@echo "Stopping RDTClient service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml stop rdtclient
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml rm -f rdtclient
	@echo "RDTClient service stopped successfully."

rdtclient-start: ## Start RDTClient service
	@echo "Starting RDTClient service..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/mediastack/.env -f docker-compose.yaml -f $(SERVICES_DIR)/mediastack/docker-compose.mediastack.yaml up rdtclient -d
	@echo "RDTClient service started successfully."

rdtclient-restart: ## Restart RDTClient service
	@echo "Restarting RDTClient service..."
	$(MAKE) rdtclient-stop
	$(MAKE) rdtclient-start
	@echo "RDTClient service restarted successfully."

rdtclient-logs: ## View logs of RDTClient
	@echo "Showing logs for RDTClient..."
	docker compose --env-file .env --env-file=./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml logs -f rdtclient

rdtclient-shell: ## Open a shell in the RDTClient container
	docker compose --env-file .env --env-file ./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml exec -it rdtclient /bin/bash