default: up view

up: view
	docker compose up -d

# run with local data dir & external pg
run: pg
	mkdir -p /data/bytebase/data;
	docker run --init --name bytebase \
        --restart always --detach \
        --publish 8887:8887 \
        --volume /data/bytebase/data:/var/opt/bytebase \
        bytebase/bytebase:2.10.0 \
        --data /var/opt/bytebase \
        --external-url http://ddl.pigsty \
        --port 8887 \
        --pg=postgresql://dbuser_bytebase:DBUser.Bytebase@10.10.10.10:5432/bytebase

view:
	@echo "visit http://ddl.pigsty  or  http://10.10.10.10:8887"

log:
	docker logs -f bytebase

info:
	docker inspect bytebase | jq

# prepare external pg
pg:
	@echo "pg_users:     { name: dbuser_bytebase , password: DBUser.Bytebase, roles: [ dbrole_admin ] }"
	@echo "pg_databases: { name: bytebase, owner: dbuser_bytebase, comment: bytebase primary database }"
	@echo "bin/pgsql-user pg-meta dbuser_bytebase ; bin/pgsql-db pg-meta bytebase"

stop:
	docker stop bytebase;

clean:
	docker stop bytebase; docker rm -f bytebase

pull:
	docker pull bytebase/bytebase:2.10.0

rmi:
	docker rmi bytebase/bytebase:2.10.0

save:
	mkdir -p /tmp/docker
	docker save bytebase/bytebase:2.10.0 | gzip -9 -c > /tmp/docker/bytebase.tgz

load:
	cat /tmp/docker/bytebase.tgz | gzip -d -c - | docker load

.PHONY: default up run view log info stop clean conf dump pull rmi save load