default: up view
up:
	docker-compose up -d

run:
	docker run --init --name pg_exporter -p 9630:9630 -e PG_EXPORTER_URL='postgres://dbuser_monitor:DBUser.Monitor@10.10.10.10:5432/postgres?sslmode=disable&host=/var/run/postgresql' vonng/pg_exporter

view:
	curl http://localhost:9630/metrics

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
	docker save vonng/pg_exporter | lz4 -c > /tmp/pg_exporter.tlz

load:
	cat /tmp/pg_exporter.tlz | lz4 -d -c - | docker load

.PHONY: default up run view log info stop clean pull rmi save load