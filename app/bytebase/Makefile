default: up view

# minimal setup with internal pg & dir
up: view
	docker-compose up -d

# run with local data dir & external pg
run: pg
	mkdir -p /data/bytebase/data;
	docker run --init --name bytebase \
        --restart always --detach \
        --publish 8887:8887 \
        --volume /data/bytebase/data:/var/opt/bytebase \
        bytebase/bytebase:1.8.0 \
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
	@echo "bin/createuser pg-meta dbuser_bytebase ; bin/createdb pg-meta bytebase"

stop:
	docker stop bytebase;

clean:
	docker stop bytebase; docker rm -f bytebase

pull:
	docker pull bytebase/bytebase4

rmi:
	docker rmi bytebase/bytebase4

save:
	docker save bytebase/bytebase4 | lz4 -c > /tmp/bytebase.tlz

load:
	cat /tmp/bytebase.tlz | lz4 -d -c - | docker load

.PHONY: default up run view log info stop clean conf dump pull rmi save load