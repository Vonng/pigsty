default: up view

# minimal setup with internal pg & dir
up: view
	docker-compose up -d

view:
	@echo "visit http://ddl.pigsty  or  http://10.10.10.10:8887"

log:
	docker logs -f gitea

info:
	docker inspect gitea | jq

# prepare external pg
pg:
	@echo "pg_users:     { name: dbuser_gitea , password: DBUser.gitea, roles: [ dbrole_admin ] }"
	@echo "pg_databases: { name: gitea, owner: dbuser_gitea, comment: gitea primary database }"
	@echo "bin/createuser pg-meta dbuser_gitea ; bin/createdb pg-meta gitea"

stop:
	docker stop gitea;

clean:
	docker stop gitea; docker rm -f gitea

pull:
	docker pull gitea/gitea4

rmi:
	docker rmi gitea/gitea4

save:
	docker save gitea/gitea4 | lz4 -c > /tmp/gitea.tlz

load:
	cat /tmp/gitea.tlz | lz4 -d -c - | docker load

.PHONY: default up run view log info stop clean conf dump pull rmi save load