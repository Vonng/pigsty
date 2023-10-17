default: up view

DOCKER_IMAGE_DIR=/tmp/docker/supabase

up: view
	docker compose up -d

view:
	@echo "visit http://10.10.10.10:8000 for supabase studio"

log:
	docker logs -f supabase-studio

info:
	docker inspect supabase-studio | jq

stop:
	docker compose down

clean:
	docker compose down

pull:
	docker compose pull

save:
	mkdir -p $(DOCKER_IMAGE_DIR)
	docker save supabase/studio        | gzip -c -9 > $(DOCKER_IMAGE_DIR)/studio.tgz
	docker save supabase/realtime      | gzip -c -9 > $(DOCKER_IMAGE_DIR)/realtime.tgz
	docker save supabase/gotrue        | gzip -c -9 > $(DOCKER_IMAGE_DIR)/gotrue.tgz
	docker save supabase/storage-api   | gzip -c -9 > $(DOCKER_IMAGE_DIR)/storage-api.tgz
	docker save supabase/edge-runtime  | gzip -c -9 > $(DOCKER_IMAGE_DIR)/edge-runtime.tgz
	docker save supabase/postgres-meta | gzip -c -9 > $(DOCKER_IMAGE_DIR)/postgres-meta.tgz
	docker save supabase/logflare      | gzip -c -9 > $(DOCKER_IMAGE_DIR)/logflare.tgz
	docker save darthsim/imgproxy      | gzip -c -9 > $(DOCKER_IMAGE_DIR)/imgproxy.tgz
	docker save postgrest/postgrest    | gzip -c -9 > $(DOCKER_IMAGE_DIR)/postgrest.tgz
	docker save kong                   | gzip -c -9 > $(DOCKER_IMAGE_DIR)/kong.tgz

tarball: save
	tar -cvf /tmp/supabase.tgz -C /tmp/docker supabase

load:
	cat $(DOCKER_IMAGE_DIR)/studio.tgz         | gzip -d -c - | docker load
	cat $(DOCKER_IMAGE_DIR)/realtime.tgz       | gzip -d -c - | docker load
	cat $(DOCKER_IMAGE_DIR)/gotrue.tgz         | gzip -d -c - | docker load
	cat $(DOCKER_IMAGE_DIR)/storage-api.tgz    | gzip -d -c - | docker load
	cat $(DOCKER_IMAGE_DIR)/edge-runtime.tgz   | gzip -d -c - | docker load
	cat $(DOCKER_IMAGE_DIR)/postgres-meta.tgz  | gzip -d -c - | docker load
	cat $(DOCKER_IMAGE_DIR)/logflare.tgz       | gzip -d -c - | docker load
	cat $(DOCKER_IMAGE_DIR)/imgproxy.tgz       | gzip -d -c - | docker load
	cat $(DOCKER_IMAGE_DIR)/postgrest.tgz      | gzip -d -c - | docker load
	cat $(DOCKER_IMAGE_DIR)/kong.tgz           | gzip -d -c - | docker load


.PHONY: default up view log info stop clean pull save load