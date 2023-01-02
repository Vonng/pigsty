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
	sudo mkdir /data/minio

run:
	docker run -p 9000:9000 -p 8890:8890 -e "MINIO_ROOT_USER=admin" -e "MINIO_ROOT_PASSWORD=pigsty.minio"  minio/minio server /data --console-address ":8890"

view:
	@echo "visit http://10.10.10.10:9000 with admin : pigsty.minio"

log:
	docker logs -f minio

info:
	docker inspect minio | jq

stop:
	docker stop minio;

clean:
	docker stop minio; docker rm -f minio

pull:
	docker pull minio/minio

rmi:
	docker rmi minio/minio

save:
	docker save minio/minio | lz4 -c > /tmp/minio.tlz

load:
	cat /tmp/minio.tlz | lz4 -d -c - | docker load

.PHONY: default up run view log info stop clean pull rmi save load