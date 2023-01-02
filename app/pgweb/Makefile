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

run:
	docker run --init --name pgweb --restart always --detach --publish 8886:8081 sosedoff/pgweb

view:
	@echo "visit http://cli.pigsty  or  http://10.10.10.10:8886"
	@echo "example url: postgres://dbuser_meta:DBUser.Meta@10.10.10.10:5432/meta?sslmode=disable"

log:
	docker logs -f pgweb

info:
	docker inspect pgweb | jq

stop:
	docker stop pgweb;

clean:
	docker stop pgweb; docker rm -f pgweb

pull:
	docker pull sosedoff/pgweb

rmi:
	docker rmi sosedoff/pgweb

save:
	docker save sosedoff/pgweb | lz4 -c > /tmp/pgweb.tlz

load:
	cat /tmp/pgweb.tlz | lz4 -d -c - | docker load

.PHONY: default up run view log info stop clean pull rmi save load