default: up view

up: view
	docker compose up -d

# run with local data dir & external pg
run: pg
	docker run --init --name odoo --restart always --detach --publish 8069:8069 odoo:17.0

view:
	@echo "visit http://odoo.pigsty  or  http://10.10.10.10:8069"

log:
	docker logs -f odoo

info:
	docker inspect odoo | jq

# prepare external pg
pg:
	@echo "pg_users: { name: dbuser_odoo , password: DBUser.Odoo, createdb: true, roles: [dbrole_admin] }"
	@echo "bin/pgsql-user pg-meta dbuser_odoo

stop:
	docker stop odoo;

clean:
	docker stop odoo; docker rm -f odoo

pull:
	docker compose pull

rmi:
	docker rmi odoo:17.0

save:
	mkdir -p /tmp/docker
	docker save odoo/odoo:17.0 | gzip -9 -c > /tmp/docker/odoo.tgz

load:
	cat /tmp/docker/odoo.tgz | gzip -d -c - | docker load

.PHONY: default up run view log info stop clean conf dump pull rmi save load