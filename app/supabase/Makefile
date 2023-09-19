`default: up view

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
	docker stop supabase; docker rm -f supabase

pull:
	docker compose pull


save:
	mkdir -p /tmp/docker
	docker save supabase/edge-runtime  | gzip -c > /tmp/docker/edge-runtime.tgz 
	docker save supabase/postgres-meta | gzip -c > /tmp/docker/postgres-meta.tgz
	docker save supabase/logflare      | gzip -c > /tmp/docker/logflare.tgz     
	docker save supabase/studio        | gzip -c > /tmp/docker/studio.tgz       
	docker save supabase/gotrue        | gzip -c > /tmp/docker/gotrue.tgz       
	docker save supabase/storage-api   | gzip -c > /tmp/docker/storage-api.tgz  
	docker save supabase/realtime      | gzip -c > /tmp/docker/realtime.tgz     
	docker save postgrest/postgrest    | gzip -c > /tmp/docker//postgrest.tgz   
	docker save darthsim/imgproxy      | gzip -c > /tmp/docker/imgproxy.tgz     
	docker save kong                   | gzip -c > /tmp/docker/kong.tgz             

load:
	cat /tmp/docker/edge-runtime.tgz   | gzip -d -c - | docker load 
	cat /tmp/docker/postgres-meta.tgz  | gzip -d -c - | docker load 
	cat /tmp/docker/logflare.tgz       | gzip -d -c - | docker load 
	cat /tmp/docker/studio.tgz         | gzip -d -c - | docker load 
	cat /tmp/docker/gotrue.tgz         | gzip -d -c - | docker load 
	cat /tmp/docker/storage-api.tgz    | gzip -d -c - | docker load 
	cat /tmp/docker/realtime.tgz       | gzip -d -c - | docker load 
	cat /tmp/docker//postgrest.tgz     | gzip -d -c - | docker load 
	cat /tmp/docker/imgproxy.tgz       | gzip -d -c - | docker load 
	cat /tmp/docker/kong.tgz           | gzip -d -c - | docker load 


.PHONY: default up run ui rmui view log info stop clean pull rmi save load