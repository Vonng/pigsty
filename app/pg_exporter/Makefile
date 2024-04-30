default: up

up:
	docker compose up -d

run:
	docker run --init --name pg_exporter -p 9632:9630 -e PG_EXPORTER_URL='postgres://dbuser_dba:DBUser.DBA@10.10.10.10:5432/postgres?sslmode=disable' vonng/pg_exporter

view:
	curl http://localhost:9632/metrics

log:
	docker logs -f pg_exporter

info:
	docker inspect pg_exporter | jq

stop:
	docker stop pg_exporter;

clean:
	docker stop pg_exporter; docker rm -f pg_exporter

pull:
	docker pull vonng/pg_exporter

rmi:
	docker rmi vonng/pg_exporter

save:
	mkdir -p /tmp/docker
	docker save Vonng/pg_exporter | gzip -9 -c > /tmp/docker/pg_exporter.tgz

load:
	cat /tmp/docker/pg_exporter.tgz | gzip -d -c - | docker load

.PHONY: default up run view log info stop clean pull rmi save load