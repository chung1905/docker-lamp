# Convenience wrapper around `dclamp` + `docker compose`.
#
# `docker-compose.yml` is a generated artifact (see dclamp / .gitignore). The
# targets below keep it in sync with dclamp.env + compose-declaration.yml
# automatically, so you no longer have to remember to run `dclamp` before
# `docker compose up`. Just run `make up`.
#
# Common usage:
#   make config          # first-time interactive setup of dclamp.env
#   make up              # (re)generate if needed, then start the stack
#   make logs S=httpd    # tail logs for one service
#   make down

CONFIG  ?= dclamp.env
COMPOSE ?= docker compose
S       ?=              # service name for `make logs`

.DEFAULT_GOAL := help

# Regenerate docker-compose.yml ONLY when one of its inputs is newer. This is
# the whole point: the generated file becomes a proper build artifact.
docker-compose.yml: $(CONFIG) compose-declaration.yml dclamp
	./dclamp generate --config $(CONFIG)

# If the config file is missing, fail with a friendly hint instead of make's
# cryptic "No rule to make target". When it exists this rule is a no-op.
$(CONFIG):
	@echo "No '$(CONFIG)' found — run 'make config' first (interactive)." >&2
	@exit 1

.PHONY: help config generate up down stop restart ps logs build pull

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2}'

config: ## Interactive setup of dclamp.env (PHP versions + services)
	./dclamp config

generate: docker-compose.yml ## Regenerate docker-compose.yml if inputs changed
	@echo "docker-compose.yml is in sync with $(CONFIG)."

up: docker-compose.yml ## Regenerate if needed, then start the stack detached
	$(COMPOSE) up -d

down: ## Stop and remove containers
	$(COMPOSE) down

stop: ## Stop containers without removing them
	$(COMPOSE) stop

restart: ## Restart containers
	$(COMPOSE) restart

ps: ## List services
	$(COMPOSE) ps

logs: ## Tail logs (all, or one service via S=<name>)
	$(COMPOSE) logs -f $(S)

build: docker-compose.yml ## Build/rebuild images
	$(COMPOSE) build

pull: ## Pull upstream images
	$(COMPOSE) pull
