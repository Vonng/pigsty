default: up view

# minimal setup with internal pg & dir
up: view
	docker-compose up -d

view:
	@echo "docker run --rm -it --network=ferretdb --entrypoint=mongosh mongo:5 mongodb://ferretdb/"

log:
	docker logs -f ferretdb

info:
	docker inspect ferretdb | jq

stop:
	docker stop ferretdb;

clean:
	docker stop ferretdb; docker rm -f ferretdb

pull:
	docker pull ferretdb/ferretdb4

rmi:
	docker rmi ferretdb/ferretdb4

save:
	docker save ferretdb/ferretdb4 | lz4 -c > /tmp/ferretdb.tlz

load:
	cat /tmp/ferretdb.tlz | lz4 -d -c - | docker load

.PHONY: default up run view log info stop clean conf dump pull rmi save load