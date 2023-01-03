default: up view
up:
	docker-compose up -d

ui:
	docker run --init --name pgweb --name swagger -p 8882:8080 -e API_URL=http://10.10.10.10:8884 swaggerapi/swagger-ui

log:
	docker logs -f kong

info:
	docker inspect kong | jq

stop:
	docker stop kong;

clean:
	docker stop kong; docker rm -f kong


pull:
	docker pull kong

rmi:
	docker rmi kong

save:
	mkdir -p /tmp/docker
	docker save kong | gzip -9 -c > /tmp/docker/kong.tgz

load:
	cat /tmp/docker/kong.tgz | gzip -d -c - | docker load

.PHONY: default up run view log info stop clean pull rmi save load