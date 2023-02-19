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
	docker run --init --name postgrest --restart always --detach --publish 8884:8081 postgrest/postgrest

ui:
	docker run --init --name pgweb --name swagger -p 8882:8080 -e API_URL=http://10.10.10.10:8884 swaggerapi/swagger-ui

view:
	@echo "visit http://10.10.10.10:8884 for API Spec"

log:
	docker logs -f postgrest

info:
	docker inspect postgrest | jq

stop:
	docker stop postgrest;

clean:
	docker stop postgrest; docker rm -f postgrest

rmui:
	docker stop swagger; docker rm swagger

pull:
	docker pull postgrest/postgrest

rmi:
	docker rmi postgrest/postgrest

save:
	mkdir -p /tmp/docker
	docker save postgrest/postgrest | gzip -9 -c > /tmp/docker/postgrest.tgz

load:
	cat /tmp/docker/postgrest.tgz | gzip -d -c - | docker load

.PHONY: default up run ui rmui view log info stop clean pull rmi save load