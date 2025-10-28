# Inception (Dockerized NGINX + WordPress + MariaDB)

This repository sets up a small infrastructure using Docker Compose with three services:

- NGINX (TLS 1.2/1.3 only) — sole entry point on port 443
- WordPress (php-fpm only; no NGINX)
- MariaDB (database only; no NGINX)

Two bind-mounted volumes persist data on the host VM:
- /home/asadiqui/data/db — MariaDB data
- /home/asadiqui/data/wp — WordPress site files

A single user-defined Docker network `inception` connects the services. Containers are configured to auto-restart.

## Prerequisites
- Run this inside a Linux virtual machine (as required by the subject)
- Docker and Docker Compose plugin installed
- Update your /etc/hosts (on your local machine) to map your domain to your VM IP if needed, e.g.
  192.168.56.10 asadiqui.42.fr

## Configuration
1. Copy srcs/.env and adjust the non-secret variables:
   - DOMAIN_NAME, MARIADB_DATABASE, MARIADB_USER, MARIADB_HOST
   - WP_TITLE, WP_ADMIN_USER, WP_ADMIN_EMAIL, WP_USER, WP_USER_EMAIL
2. Put passwords in the ./secrets folder (do NOT commit these):
   - secrets/db_root_password.txt
   - secrets/db_password.txt
   - secrets/wp_admin_password.txt
   - secrets/wp_user_password.txt

Passwords must not be present in Dockerfiles; this stack uses Docker secrets instead.

## How to run
Use the Makefile targets (they call docker compose under the hood):

- make all — create data folders, build images, and start the stack
- make build — build images
- make up — start (detached)
- make logs — tail logs
- make down — stop and remove containers
- make clean — down + remove volumes (Compose) and orphans
- make fclean — clean + remove host bind volumes under /home/asadiqui/data
- make re — rebuild everything from scratch

Once up, visit https://asadiqui.42.fr (self-signed certificate by default).

## Notes
- NGINX auto-generates a self-signed certificate at container start (TLS v1.2/v1.3 only). Replace with a real cert as desired by mounting /etc/nginx/certs with your own server.crt and server.key.
- The WordPress container installs WP via wp-cli on first run and creates two users (an admin and a secondary user) per the subject rules.
- No container uses infinite loops or tail -f; all services run their daemons in the foreground as PID 1.

## Directory Structure (excerpt)
- Makefile — entry point for build/run tasks
- secrets/ — Docker secrets (password files)
- srcs/.env — non-secret environment variables
- srcs/docker-compose.yml — service orchestration
- srcs/requirements/mariadb — MariaDB Dockerfile and init script
- srcs/requirements/wordpress — WordPress (php-fpm) Dockerfile and setup script
- srcs/requirements/nginx — NGINX Dockerfile, TLS config, and entrypoint
