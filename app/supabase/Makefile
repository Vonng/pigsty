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
	docker save supabase/storage-api   | gzip -c -9 > $(IMG_DIR)/storage.tgz
	docker save darthsim/imgproxy      | gzip -c -9 > $(IMG_DIR)/imgproxy.tgz
	docker save supabase/studio        | gzip -c -9 > $(IMG_DIR)/studio.tgz
	docker save supabase/realtime      | gzip -c -9 > $(IMG_DIR)/realtime.tgz
	docker save supabase/edge-runtime  | gzip -c -9 > $(IMG_DIR)/edge.tgz
	docker save supabase/gotrue        | gzip -c -9 > $(IMG_DIR)/gotrue.tgz
	docker save supabase/postgres-meta | gzip -c -9 > $(IMG_DIR)/postgres.tgz
	docker save supabase/logflare      | gzip -c -9 > $(IMG_DIR)/logflare.tgz
	docker save postgrest/postgrest    | gzip -c -9 > $(IMG_DIR)/postgrest.tgz
	docker save timberio/vector        | gzip -c -9 > $(IMG_DIR)/vector.tgz
	docker save kong                   | gzip -c -9 > $(IMG_DIR)/kong.tgz

# copy to target machine: scp -r /tmp/docker xxx:/tmp/docker
tz: tarball
tarball: save
	tar -cvf /tmp/supabase.tgz -C /tmp/docker supabase

copy:
	ssh 10.10.10.10 'mkdir -p /tmp/docker/supabase'
	rsync -avz /tmp/docker/supabase/ 10.10.10.10:/tmp/docker/supabase/

load:
	cat $(IMG_DIR)/storage.tgz   | gzip -d -c - | docker load
	cat $(IMG_DIR)/imgproxy.tgz  | gzip -d -c - | docker load
	cat $(IMG_DIR)/studio.tgz    | gzip -d -c - | docker load
	cat $(IMG_DIR)/realtime.tgz  | gzip -d -c - | docker load
	cat $(IMG_DIR)/edge.tgz      | gzip -d -c - | docker load
	cat $(IMG_DIR)/gotrue.tgz    | gzip -d -c - | docker load
	cat $(IMG_DIR)/postgres.tgz  | gzip -d -c - | docker load
	cat $(IMG_DIR)/logflare.tgz  | gzip -d -c - | docker load
	cat $(IMG_DIR)/postgrest.tgz | gzip -d -c - | docker load
	cat $(IMG_DIR)/vector.tgz    | gzip -d -c - | docker load
	cat $(IMG_DIR)/kong.tgz      | gzip -d -c - | docker load


.PHONY: default up down view log info restart clean edit pull save load tz tarball