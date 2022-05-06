default: up view
up:
	docker-compose up -d

run:
	docker run --init --name postgrest --restart always --detach --publish 8884:8081 postgrest/postgrest

ui:
	docker run --init --name pgweb --name swagger -p 8882:8080 -e API_URL=http://10.10.10.10:8884 swaggerapi/swagger-ui

view:
	@echo "visit http://10.10.10.10:8884"

log:
	docker logs -f postgrest

info:
	docker inspect postgrest | jq

stop:
	docker stop postgrest;

clean:
	docker stop postgrest; docker rm -f postgrest

rmui:
	docker stop swagger; docker rm swagger

pull:
	docker pull postgrest/postgrest

rmi:
	docker rmi postgrest/postgrest

save:
	docker save postgrest/postgrest | lz4 -c > /tmp/postgrest.tlz

load:
	cat /tmp/postgrest.tlz | lz4 -d -c - | docker load

.PHONY: default up run ui rmui view log info stop clean pull rmi save load