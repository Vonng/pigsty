default: up view

DOCKER_IMAGE_DIR=/tmp/docker/dify

up: view
	docker compose up -d

view:
	cat .env | grep -A 1 DIFY_PORT

log:
	docker compose logs -f

info:
	docker compose ps

down: stop
stop:
	docker compose down

clean:
	docker compose rm
	sudo rm -rf volumes/app;
	@echo "dont' forget to nuke the dify database in postgres"

pg:
	@echo "cd ~/pigsty"
	@echo "bin/pgsql-user pg-meta dbuser_dify"
	@echo "bin/pgsql-db   pg-meta dify"

pull:
	docker compose pull

save:
	mkdir -p $(DOCKER_IMAGE_DIR)
	docker save langgenius/dify-api:0.6.11 | gzip -c -9 > $(DOCKER_IMAGE_DIR)/dify-api.tgz
    docker save langgenius/dify-web:0.6.11 | gzip -c -9 > $(DOCKER_IMAGE_DIR)/dify-web.tgz

tarball: save
	tar -cvf /tmp/dify.tgz -C /tmp/docker dify

load:
	cat $(DOCKER_IMAGE_DIR)/dify-api.tgz       | gzip -d -c - | docker load
	cat $(DOCKER_IMAGE_DIR)/dify-web.tgz       | gzip -d -c - | docker load
