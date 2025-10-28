# Inception project Makefile

COMPOSE_FILE := srcs/docker-compose.yml
ENV_FILE := srcs/.env
DATA_DIR := /home/asadiqui/data
DB_DIR := $(DATA_DIR)/db
WP_DIR := $(DATA_DIR)/wp

DC := docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)

.PHONY: all up build down stop restart logs clean fclean re mkdata status

all: mkdata build up

mkdata:
	@mkdir -p $(DB_DIR) $(WP_DIR)
	@echo "Ensured data directories exist at $(DATA_DIR)"

build:
	$(DC) build --no-cache

up:
	$(DC) up -d

down:
	$(DC) down

stop:
	$(DC) stop

restart:
	$(DC) down
	$(DC) up -d --build

logs:
	$(DC) logs -f --tail=200

status:
	$(DC) ps

clean:
	$(DC) down -v --remove-orphans

fclean: clean
	@rm -rf $(DB_DIR) $(WP_DIR)
	@echo "Removed host bind volumes under $(DATA_DIR)"

re: fclean all
