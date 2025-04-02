SERVICES_DIR=./services
TRAFFIC_COMPOSE=./traefik/docker-compose.traefik.yaml
# ACTIVE_SERVICES=$(shell grep ^ACTIVE_SERVICES .env | cut -d '=' -f2)
ACTIVE_SERVICES=$(shell grep ^ACTIVE_SERVICES .env | cut -d '=' -f2 | sed 's/,$$//' | sed 's/,/ /g')


.PHONY: start start-service stop default list help
help: ## Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done | column -t -c 2 -s ':#'


start: ## Up Traefik and active services by default
	@echo "Starting base (Traefik)..."
	docker compose --env-file .env -f docker-compose.yaml -f $(TRAFFIC_COMPOSE) up -d
	@echo "Base started successfully."

	@echo "Starting active services..."
	@for SERVICE in $(ACTIVE_SERVICES); do \
		echo "Starting $$SERVICE..."; \
		docker compose --env-file .env --env-file $(SERVICES_DIR)/$$SERVICE/.env -f docker-compose.yaml -f $(SERVICES_DIR)/$$SERVICE/docker-compose.$$SERVICE.yaml up -d; \
	done
	@echo "All active services started successfully."

start-traefik: ## Up Traefik only
	@echo "Starting base (Traefik)..."
	docker compose --env-file .env -f docker-compose.yaml -f $(TRAFFIC_COMPOSE) up -d
	@echo "Base started successfully."

start-service: ## Up a specific service (make start-service SERVICE=service_name)
	@echo "Starting service $(SERVICE)..."
	docker compose --env-file .env --env-file $(SERVICES_DIR)/$$SERVICE/.env -f docker-compose.yaml -f $(SERVICES_DIR)/$$SERVICE/docker-compose.$$SERVICE.yaml up -d

stop:
	@echo "Stopping Traefik and active services..."
	docker compose --env-file .env -f docker-compose.yaml -f $(TRAFFIC_COMPOSE) down
	@for SERVICE in $(ACTIVE_SERVICES); do \
		docker compose --env-file .env --env-file $(SERVICES_DIR)/$$SERVICE/.env -f docker-compose.yaml -f $(SERVICES_DIR)/$$SERVICE/docker-compose.$$SERVICE.yaml down; \
	done
	@echo "All services stopped successfully."

restart:
	@echo "Restarting Traefik and active services..."
	$(MAKE) stop
	$(MAKE) start
   	

logs: ## View logs of Traefik and all active services
	@echo "Showing logs for Traefik..."
	docker compose --env-file .env -f docker-compose.yaml -f $(TRAFFIC_COMPOSE) logs -f &
	@echo "Showing logs for active services..."
	@for SERVICE in $(ACTIVE_SERVICES); do \
		echo "Showing logs for $$SERVICE..."; \
		docker compose --env-file .env --env-file $(SERVICES_DIR)/$$SERVICE/.env -f docker-compose.yaml -f $(SERVICES_DIR)/$$SERVICE/docker-compose.$$SERVICE.yaml logs -f & \
	done
	@wait

	# @echo "Showing logs for Traefik..."
	# docker compose --env-file .env -f docker-compose.yaml -f $(TRAFFIC_COMPOSE) $(foreach SERVICE,$(ACTIVE_SERVICES),-f $(SERVICES_DIR)/$(SERVICE)/docker-compose.$(SERVICE).yml) logs -f

	# docker compose --env-file .env -f docker-compose.yaml -f $(TRAFFIC_COMPOSE) logs -f &
	# @echo "Showing logs for active services..."
	# @for SERVICE in $(ACTIVE_SERVICES); do \
	# 	docker compose --env-file .env --env-file $(SERVICES_DIR)/$$SERVICE/.env -f docker-compose.yaml -f $(SERVICES_DIR)/$$SERVICE/docker-compose.$$SERVICE.yaml logs -f & \
	# done
	# @wait

logs-service: ## View logs of a specific service (make logs-service SERVICE=service_name)
	@echo "Showing logs for $(SERVICE)..."
	docker compose --env-file .env -f docker-compose.yaml -f $(SERVICES_DIR)/$(SERVICE)/docker-compose.$(SERVICE).yaml logs -f

logs-traefik: ## View logs of Traefik only
	@echo "Showing logs for Traefik..."
	docker compose --env-file .env -f docker-compose.yaml -f $(TRAFFIC_COMPOSE) logs -f

shell-traefik:
	docker compose --env-file .env -f docker-compose.yaml -f $(TRAFFIC_COMPOSE) exec -it traefik /bin/sh

list: ## List all active services
	@echo "Active services configured in .env: $(ACTIVE_SERVICES)"
