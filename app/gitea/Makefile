ifeq (, $(shell which docker-compose 2>/dev/null))
DOCKER_COMPOSE_PLUGIN="true"
endif

default: up view

up: view
ifdef DOCKER_COMPOSE_PLUGIN
	docker compose up -d
else
	docker-compose up -d
endif

view:
	@echo "visit http://git.pigsty  or  http://10.10.10.10:8889"

log:
	docker logs -f gitea

info:
	docker inspect gitea | jq

# prepare external pg
pg:
	@echo "pg_users:     { name: dbuser_gitea , password: DBUser.Gitea, roles: [ dbrole_admin ] }"
	@echo "pg_databases: { name: gitea, owner: dbuser_gitea, comment: gitea primary database }"
	@echo "bin/createuser pg-meta dbuser_gitea ; bin/createdb pg-meta gitea"

stop:
	docker stop gitea;

clean:
	docker stop gitea; docker rm -f gitea

pull:
	docker pull gitea/gitea

rmi:
	docker rmi gitea/gitea

save:
	docker save gitea/gitea | lz4 -c > /tmp/gitea.tlz

load:
	cat /tmp/gitea.tlz | lz4 -d -c - | docker load

.PHONY: default up run view log info stop clean pull rmi save load