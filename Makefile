# tools
SHELL := /bin/bash

# env vars
NB_UID := $(shell id -u)
NB_GID := $(shell id -g)

# Default command and help messages
.PHONY: default help
default: help

shell:     ## Run a bash shell inside the app container
up:        ## Launch the dev environment

.PHONY: up
up:
		NB_UID=${NB_UID} NB_GID=${NB_GID} docker-compose up

.PHONY: shell
shell:
	@docker-compose exec notebook bash
