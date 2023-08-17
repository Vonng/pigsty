default: up view

up: view
	docker compose up -d

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
	mkdir -p /tmp/docker
	docker save minio | gzip -9 -c > /tmp/docker/minio.tgz

load:
	cat /tmp/docker/minio.tgz | gzip -d -c - | docker load

.PHONY: default up run view log info stop clean pull rmi save load