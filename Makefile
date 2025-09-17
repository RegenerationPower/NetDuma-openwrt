SHELL=/bin/bash

COMPOSE_RUN = docker compose run --rm openwrt

.PHONY: help all setup build shell clean smoke-test

all: build

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  all          (Default) Alias for 'build'."
	@echo "  setup        Run the first-time setup: create .env and download SDKs."
	@echo "  build        Build the .ipk packages for all targets."
	@echo "  shell        Enter an interactive shell inside the development container."
	@echo "  clean        Remove downloaded SDKs and build artifacts."
	@echo "  clean-docker Remove the Docker image."

setup:
	@echo "Running first-time setup..."
	@if [ ! -f .env ]; then \
		echo "Creating .env file..."; \
		cp .env.example .env; \
	else \
		echo ".env file already exists. Skipping."; \
	fi
	@./setup_sdks.sh

build: setup
	@echo "Setting up build environment..."
	@echo "UID=$(shell id -u)" > .env
	@echo "GID=$(shell id -g)" >> .env
	@echo "USER=$(shell whoami)" >> .env
	@echo "Starting the full build process inside Docker..."
	$(COMPOSE_RUN) ./build.sh

shell: setup
	@echo "Entering interactive shell..."
	$(COMPOSE_RUN)

clean:
	@echo "Cleaning up project directory..."
	@read -p "This will remove SDKs and all build outputs. Are you sure? [y/N] " confirm && \
	if [ "$$confirm" = "y" ]; then \
		rm -rf openwrt-sdk-*/; \
		rm -rf output/; \
		echo "Cleanup complete."; \
	else \
		echo "Cleanup cancelled."; \
	fi

clean-docker:
	@echo "Removing Docker image..."
	docker compose down --rmi all || true
