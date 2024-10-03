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