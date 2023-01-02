ifeq (, $(shell which docker-compose 2>/dev/null))
DOCKER_COMPOSE_PLUGIN="true"
endif

default: up view

up: view
ifdef DOCKER_COMPOSE_PLUGIN
	docker compose up -d
else
	docker-compose up -d
endif

log:
	docker logs -f wiki

info:
	docker inspect wiki | jq

stop:
	docker stop wiki;

clean:
	docker stop wiki; docker rm -f wiki


pull:
	docker pull wiki

rmi:
	docker rmi wiki

save:
	docker save wiki | lz4 -c > /tmp/wiki.tlz

load:
	cat /tmp/wiki.tlz | lz4 -d -c - | docker load

.PHONY: default up run view log info stop clean pull rmi save load