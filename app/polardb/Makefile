default: up view

up: view
	docker compose up -d

run: pg
	mkdir -p /data/polardb;
	docker run -it \
        -v /data/polardb:/var/polardb \
        --shm-size=512m --cap-add=SYS_PTRACE --privileged=true \
        -p 5532:5532 \
        --name polardb \
        polardb/polardb_pg_local_instance \
        echo 'done'

view:
	@echo psql -p 5532 -U postgres (default password: postgres)

log:
	docker logs -f polardb

info:
	docker inspect polardb | jq

stop:
	docker stop polardb;

clean:
	docker stop polardb; docker rm -f polardb

pull:
	docker pull polardb/polardb_pg_local_instance

rmi:
	docker rmi polardb/polardb_pg_local_instance

save:
	mkdir -p /tmp/docker
	docker save polardb/polardb_pg_local_instance | gzip -9 -c > /tmp/docker/polardb.tgz

load:
	cat /tmp/docker/polardb.tgz | gzip -d -c - | docker load

.PHONY: default up run view log info stop clean conf dump pull rmi save load