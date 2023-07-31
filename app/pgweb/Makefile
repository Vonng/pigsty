default: up view

up: view
	docker compose up -d

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
	mkdir -p /tmp/docker
	docker save sosedoff/pgweb | gzip -9 -c > /tmp/docker/pgweb.tgz

load:
	cat /tmp/docker/pgweb.tgz | gzip -d -c - | docker load

.PHONY: default up run view log info stop clean pull rmi save load