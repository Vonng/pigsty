default: up view
up:
	docker-compose up -d

ui:
	docker run --init --name pgweb --name swagger -p 8882:8080 -e API_URL=http://10.10.10.10:8884 swaggerapi/swagger-ui

view:
	@echo "visit http://10.10.10.10:8884"

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
	docker save kong | lz4 -c > /tmp/kong.tlz

load:
	cat /tmp/kong.tlz | lz4 -d -c - | docker load

.PHONY: default up run view log info stop clean pull rmi save load