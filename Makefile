PWD = $(shell pwd)
PROJECT_NAME = flask-template
API=api
DOCKER_COMPOSE=docker-compose -p ${PROJECT_NAME} -f ${PWD}/ops/docker/docker-compose.yml
GREEN=\033[0;32m
RESET=\033[0m
UNAME := $(shell uname)

.EXPORT_ALL_VARIABLES:

.PHONY: help
help:
ifeq ($(UNAME), Linux)
	@grep -P '^[a-zA-Z_-]+:.*?### .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?### "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
else
	@awk -F ':.*####' '$$0 ~ FS {printf "%15s%s\n", $$1 ":", $$2}' \
		$(MAKEFILE_LIST) | grep -v '@awk' | sort
endif

###@ Docker

start: build run ### Start the project

build:
	@${DOCKER_COMPOSE} build

run:
	@${DOCKER_COMPOSE} up -d

stop: ### Stop the project
	@${DOCKER_COMPOSE} down

restart: stop start ### Restart the project

###@ Migration

init-migrations: ### Initialize the migrations
	@${DOCKER_COMPOSE} exec ${API} flask db init

migrate: ### Create a new migration
	@${DOCKER_COMPOSE} exec ${API} flask db migrate

upgrade: ### Upgrade the database
	@${DOCKER_COMPOSE} exec ${API} flask db upgrade

downgrade: ### Downgrade the database
	@${DOCKER_COMPOSE} exec ${API} flask db downgrade

	###@ Tests

test: ### Run the tests
	@${DOCKER_COMPOSE} exec ${API} poetry run pytest ${ARGS}

###@ Utils

lint: ### Lint the project
	@${DOCKER_COMPOSE} exec ${API} black src/ tests/

mypy: ### Type check the project
	@${DOCKER_COMPOSE} exec ${API} mypy src/

rabbitmq: ### Open the RabbitMQ management
	open http://localhost:15672

consumer: ### Start the consumer
	@${DOCKER_COMPOSE} exec ${API} $ celery -A src.workers.make_celery.celery_app worker --loglevel INFO