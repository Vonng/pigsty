default: up view
up:
	docker-compose up -d

data:
	sudo mkdir /data/minio

run:
	docker run -p 9000:9000 -p 9001:9001 -e "MINIO_ROOT_USER=admin" -e "MINIO_ROOT_PASSWORD=pigsty.minio"  minio/minio server /data --console-address ":9001"

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