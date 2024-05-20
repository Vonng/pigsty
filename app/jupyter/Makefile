default: up view

up: view
	docker compose up -d

# make a /data/jupyter dir and change owner to default
dir:
	sudo mkdir -p /data/jupyter; sudo chown -R 1000:100 /data/jupyter

run:
	docker run --init --name jupyter --restart always --detach --publish 8886:8081 sosedoff/jupyter

view:
	@echo "visit http://cli.pigsty  or  http://10.10.10.10:8886"
	@echo "example url: postgres://dbuser_meta:DBUser.Meta@10.10.10.10:5432/meta?sslmode=disable"

log:
	docker logs -f jupyter

info:
	docker inspect jupyter | jq

stop:
	docker stop jupyter;

clean:
	docker stop jupyter; docker rm -f jupyter

# clean data
purge:
	sudo rm -rf /data/jupyter

pull:
	docker compose pull

rmi:
	docker rmi jupyter/minimal-notebook

save:
	mkdir -p /tmp/docker
	docker save sosedoff/jupyter | gzip -9 -c > /tmp/docker/jupyter.tgz

load:
	cat /tmp/docker/jupyter.tgz | gzip -d -c - | docker load

.PHONY: default up run view log info stop clean pull rmi save load