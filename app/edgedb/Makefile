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

data:
	sudo mkdir /data/edgedb

run:
	docker run -p 3001:3000 -e "EDGEDB_SERVER_PASSWORD=secret" -e "EDGEDB_SERVER_SECURITY=insecure_dev_mode" -e "EDGEDB_SERVER_BACKEND_DSN=postgres://dbuser_edge:DBUser.Edge@10.10.10.10:5432/edgedb" -d -v /data/edgedb:/var/lib/edgedb/data -n edgedb edgedb/edgedb

view:
	@echo "docker exec -it edgedb edgedb -H 127.0.0.1 -P 5656 --password --tls-security=insecure"
	@echo "default password is 'edge'"
	docker exec -it edgedb edgedb -H 127.0.0.1 -P 5656 --password --tls-security=insecure

log:
	docker logs -f edgedb

info:
	docker inspect edgedb | jq

stop:
	docker stop edgedb;

clean:
	docker stop edgedb; docker rm -f /edgedb
	rm -rf /data/edgedb

pull:
	docker pull edgedb/edgedb

rmi:
	docker rmi edgedb/edgedb

save:
	mkdir -p /tmp/docker
	docker save edgedb/edgedb | gzip -9 -c > /tmp/docker/edgedb.tgz

load:
	cat /tmp/docker/edgedb.tgz | gzip -d -c - | docker load

.PHONY: default up run view log info stop clean pull rmi save load