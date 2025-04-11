SERVICES_DIR=./services
FILE_COMMON_COMPOSE=-f ./docker-compose.yaml -f ./traefik/docker-compose.traefik.yaml -f ./pihole/docker-compose.pihole.yaml
ENV_COMMON=--env-file .env --env-file ./traefik/.env --env-file ./pihole/.env
ACTIVE_SERVICES=$(shell grep ^ACTIVE_SERVICES .env | cut -d '=' -f2 | sed 's/,$$//' | sed 's/,/ /g')


.PHONY: help list start start-base start-all-services start-service stop stop-base stop-all-services stop-service restart restart-services logs logs-base logs-all-services logs-traefik logs-traefik-access logs-pihole logs-pihole-dns logs-navidrome logs-jellyfin logs-radarr logs-sonarr logs-jackett logs-flaresolverr logs-transmission logs-service shell-traefik shell-pihole shell-jellyfin shell-radarr shell-sonarr shell-jackett shell-flaresolverr shell-transmission cmd-pihole-localdns cmd-pihole-adlists cmd-pihole-adlists-clean cmd-pihole-flushdns cmd-jellyfin-checkhw


help: ## Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done | column -t -c 2 -s ':#'

list: ## List all active services
	@echo "Active services configured in .env: $(ACTIVE_SERVICES)"


## Execution Commands ##


start: ## Up all services (Traefik, Pihole and active services)
	$(MAKE) start-base
	$(MAKE) start-all-services

start-base: ## Up common services (Traefik and Pihole)
	@echo "Starting base (Traefik, Pihole)..."
	docker compose $(ENV_COMMON) $(FILE_COMMON_COMPOSE) up -d --build
	@echo "Base started successfully."

start-all-services: ## Up all active services
	@echo "Starting active services..."
	@for SERVICE in $(ACTIVE_SERVICES); do \
		echo "Starting $$SERVICE..."; \
		docker compose --env-file .env --env-file $(SERVICES_DIR)/$$SERVICE/.env -f docker-compose.yaml -f $(SERVICES_DIR)/$$SERVICE/docker-compose.$$SERVICE.yaml up -d; \
	done
	@echo "All active services started successfully."

start-service: ## Up a specific service (make start-service SERVICE=service_name)
	@echo "Starting service $(SERVICE)..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/$$SERVICE/.env -f docker-compose.yaml -f $(SERVICES_DIR)/$$SERVICE/docker-compose.$$SERVICE.yaml up -d

stop-service: ## Down a specific service (make stop-service SERVICE=service_name)
	@echo "Stoping service $(SERVICE)..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/$$SERVICE/.env -f docker-compose.yaml -f $(SERVICES_DIR)/$$SERVICE/docker-compose.$$SERVICE.yaml down

stop: ## Stop all services (Traefik, Pihole and active services)
	$(MAKE) stop-all-services
	$(MAKE) stop-base

stop-base: # ## Stop base services (Traefik and Pihole)
	@echo "Stopping base (Traefik and Pihole)..."
	docker compose $(ENV_COMMON) $(FILE_COMMON_COMPOSE) down
	@echo "Base stopped successfully."

stop-all-services: ## Stop all active services
	@echo "Stopping all active services..."
	@for SERVICE in $(ACTIVE_SERVICES); do \
		echo "Stopping $$SERVICE..."; \
		docker compose --env-file .env --env-file $(SERVICES_DIR)/$$SERVICE/.env -f docker-compose.yaml -f $(SERVICES_DIR)/$$SERVICE/docker-compose.$$SERVICE.yaml down; \
	done
	@echo "All active services stopped successfully."

restart: ## Restart all services (Traefik, Pihole and active services)
	@echo "Restarting Traefik and active services..."
	$(MAKE) stop
	$(MAKE) start

restart-services: ## Restart all active services
	@echo "Restarting all active services..."
	@for SERVICE in $(ACTIVE_SERVICES); do \
		echo "Restarting $$SERVICE..."; \
		docker compose --env-file .env --env-file $(SERVICES_DIR)/$$SERVICE/.env -f docker-compose.yaml -f $(SERVICES_DIR)/$$SERVICE/docker-compose.$$SERVICE.yaml restart; \
	done
	@echo "All active services restarted successfully."


## Logs Commands ##


logs-base: ## View logs of common services (Traefik and Pihole)
	@echo "Showing logs for Traefik and Pihole..."
	docker compose $(ENV_COMMON) $(FILE_COMMON_COMPOSE) logs -f

logs-all-services: ## View logs of all active services
	@echo "Showing logs for all active services..."
	@for SERVICE in $(ACTIVE_SERVICES); do \
		echo "Showing logs for $$SERVICE..."; \
		docker compose --env-file .env --env-file $(SERVICES_DIR)/$$SERVICE/.env -f docker-compose.yaml -f $(SERVICES_DIR)/$$SERVICE/docker-compose.$$SERVICE.yaml logs -f; \
	done
	@wait

logs: ## View logs of common and all active services
	${MAKE} logs-base
	${MAKE} logs-all-services

logs-traefik: ## View logs of Traefik
	@echo "Showing logs for Traefik..."
	docker compose --env-file .env --env-file=./traefik/.env -f docker-compose.yaml -f ./traefik/docker-compose.traefik.yaml logs -f

logs-traefik-access: ## View Traefik access logs (tail -f /var/log/nginx/access.log)
	@echo "Showing Traefik access logs..."
	docker compose --env-file .env --env-file=./traefik/.env -f docker-compose.yaml -f ./traefik/docker-compose.traefik.yaml exec -it traefik tail -f /var/log/traefik/access.log

logs-pihole: ## View logs of Pihole
	@echo "Showing logs for Pihole..."
	docker compose --env-file .env --env-file=./pihole/.env -f docker-compose.yaml -f ./pihole/docker-compose.pihole.yaml logs -f

logs-pihole-dns: ## View Pihole DNS logs (tail -f /var/log/pihole/pihole.log)
	@echo "Showing Pihole DNS logs..."
	docker compose --env-file .env --env-file=./pihole/.env -f docker-compose.yaml -f ./pihole/docker-compose.pihole.yaml exec -it pihole tail -f /var/log/pihole/pihole.log

logs-navidrome: ## View logs of Navidrome
	@echo "Showing logs for Navidrome..."
	docker compose --env-file .env --env-file=./services/navidrome/.env -f docker-compose.yaml -f ./services/navidrome/docker-compose.navidrome.yaml logs -f

logs-jellyfin: ## View logs of Jellyfin
	@echo "Showing logs for Jellyfin..."
	docker compose --env-file .env --env-file=./services/jellyfin/.env -f docker-compose.yaml -f ./services/jellyfin/docker-compose.jellyfin.yaml logs -f

logs-radarr: ## View logs of Radarr
	@echo "Showing logs for Radarr..."
	docker compose --env-file .env --env-file=./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml logs radarr -f

logs-sonarr: ## View logs of Sonarr
	@echo "Showing logs for Sonarr..."
	docker compose --env-file .env --env-file=./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml logs sonarr -f

logs-jackett: ## View logs of Jackett
	@echo "Showing logs for Jackett..."
	docker compose --env-file .env --env-file=./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml logs jackett -f

logs-flaresolverr: ## View logs of Flaresolverr
	@echo "Showing logs for Flaresolverr..."
	docker compose --env-file .env --env-file=./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml logs flaresolverr -f

logs-transmission: ## View logs of Transmission
	@echo "Showing logs for Transmission..."
	docker compose --env-file .env --env-file=./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml logs transmission -f

logs-service: ## View logs of a specific service (make logs-service SERVICE=service_name)
	@echo "Showing logs for $(SERVICE)..."
	docker compose --env-file .env -f docker-compose.yaml -f $(SERVICES_DIR)/$(SERVICE)/docker-compose.$(SERVICE).yaml logs -f


## Shell Commands ##


shell-traefik: ## Open a shell in the Traefik container
	docker compose --env-file .env --env-file ./traefik/.env -f docker-compose.yaml -f ./traefik/docker-compose.traefik.yaml exec -it traefik /bin/sh

shell-pihole: ## Open a shell in the Pihole container
	docker compose --env-file .env --env-file ./pihole/.env -f docker-compose.yaml -f ./pihole/docker-compose.pihole.yaml exec -it pihole /bin/bash

shell-jellyfin: ## Open a shell in the Jellyfin container
	docker compose --env-file .env --env-file ./services/jellyfin/.env -f docker-compose.yaml -f ./services/jellyfin/docker-compose.jellyfin.yaml exec -it jellyfin /bin/bash

shell-radarr: ## Open a shell in the Radarr container
	docker compose --env-file .env --env-file ./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml exec -it radarr /bin/bash

shell-sonarr: ## Open a shell in the Sonarr container
	docker compose --env-file .env --env-file ./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml exec -it sonarr /bin/bash

shell-jackett: ## Open a shell in the Jackett container
	docker compose --env-file .env --env-file ./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml exec -it jackett /bin/bash

shell-flaresolverr: ## Open a shell in the Flaresolverr container
	docker compose --env-file .env --env-file ./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml exec -it flaresolverr /bin/bash

shell-transmission: ## Open a shell in the Transmission container
	docker compose --env-file .env --env-file ./services/mediastack/.env -f docker-compose.yaml -f ./services/mediastack/docker-compose.mediastack.yaml exec -it transmission /bin/bash

## Service Commands ##

cmd-pihole-localdns: ## Update local DNS records
	docker compose --env-file .env --env-file ./pihole/.env -f docker-compose.yaml -f ./pihole/docker-compose.pihole.yaml exec -u root pihole sh -c "/bin/sh /etc/custom.d/01-static-entries/update-static-records.sh"

cmd-pihole-adlists: ## Update adlists
	docker compose --env-file .env --env-file ./pihole/.env -f docker-compose.yaml -f ./pihole/docker-compose.pihole.yaml exec -u root pihole sh -c "/bin/sh /etc/custom.d/02-adlists/add-adlists.sh"

cmd-pihole-adlists-clean: ## Disable adlists
	docker compose --env-file .env --env-file ./pihole/.env -f docker-compose.yaml -f ./pihole/docker-compose.pihole.yaml exec -u root pihole sh -c "/bin/sh /etc/custom.d/02-adlists/clean-adlists.sh"

cmd-pihole-flushdns: ## Flush dns
	docker compose --env-file .env --env-file ./pihole/.env -f docker-compose.yaml -f ./pihole/docker-compose.pihole.yaml exec -u root pihole sh -c ""

cmd-jellyfin-checkhw: ## Check hardware acceleration
	@echo "Checking QSV and VA-API for Jellyfin..."
	docker compose --env-file .env --env-file ./services/jellyfin/.env -f docker-compose.yaml -f ./services/jellyfin/docker-compose.jellyfin.yaml exec -it jellyfin /bin/bash -c "/usr/lib/jellyfin-ffmpeg/vainfo"
	@echo "Checking OpenCL for Jellyfin..."
	docker compose --env-file .env --env-file ./services/jellyfin/.env -f docker-compose.yaml -f ./services/jellyfin/docker-compose.jellyfin.yaml exec -it jellyfin /bin/bash -c "/usr/lib/jellyfin-ffmpeg/ffmpeg -v verbose -init_hw_device vaapi=va -init_hw_device opencl@va"