default: up view

IMG_DIR=/tmp/docker/supabase

up:
	docker compose up -d

down:
	docker compose down

view:
	@echo "visit http://supa.pigsty for supabase studio"

log:
	docker compose logs -f

info:
	docker inspect supabase-studio | jq

restart:
	docker compose restart

clean:
	docker compose rm

edit:
	vi .env

pull:
	docker compose pull

save:
	mkdir -p $(IMG_DIR)
	docker save supabase/storage-api:v1.10.1    | gzip -c -9 > $(IMG_DIR)/storage.tgz
	docker save darthsim/imgproxy:v3.8.0        | gzip -c -9 > $(IMG_DIR)/imgproxy.tgz
	docker save supabase/studio:20240923-2e3e90 | gzip -c -9 > $(IMG_DIR)/studio.tgz
	docker save supabase/realtime:v2.30.34      | gzip -c -9 > $(IMG_DIR)/realtime.tgz
	docker save supabase/edge-runtime:v1.58.3   | gzip -c -9 > $(IMG_DIR)/edge-functions.tgz
	docker save supabase/gotrue:v2.158.1        | gzip -c -9 > $(IMG_DIR)/auth.tgz
	docker save supabase/postgres-meta:v0.83.2  | gzip -c -9 > $(IMG_DIR)/meta.tgz
	docker save postgrest/postgrest:v12.2.0     | gzip -c -9 > $(IMG_DIR)/rest.tgz
	docker save supabase/logflare:1.4.0         | gzip -c -9 > $(IMG_DIR)/analytics.tgz
	docker save kong:2.8.1                      | gzip -c -9 > $(IMG_DIR)/kong.tgz
	docker save timberio/vector:0.28.1-alpine   | gzip -c -9 > $(IMG_DIR)/vector.tgz

load:
	$(IMG_DIR)/storage.tgz        | gzip -d -c - | docker load
	$(IMG_DIR)/imgproxy.tgz       | gzip -d -c - | docker load
	$(IMG_DIR)/studio.tgz         | gzip -d -c - | docker load
	$(IMG_DIR)/realtime.tgz       | gzip -d -c - | docker load
	$(IMG_DIR)/edge-functions.tgz | gzip -d -c - | docker load
	$(IMG_DIR)/auth.tgz           | gzip -d -c - | docker load
	$(IMG_DIR)/meta.tgz           | gzip -d -c - | docker load
	$(IMG_DIR)/rest.tgz           | gzip -d -c - | docker load
	$(IMG_DIR)/analytics.tgz      | gzip -d -c - | docker load
	$(IMG_DIR)/kong.tgz           | gzip -d -c - | docker load
	$(IMG_DIR)/vector.tgz         | gzip -d -c - | docker load

tz: tarball
tarball: save
	tar -cvf /tmp/supabase.tgz -C /tmp/docker supabase

.PHONY: default up down view log info restart clean edit pull save load tz tarball