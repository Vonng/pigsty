# Odoo

[Odoo](https://www.odoo.com/), Open Source ERP.

> All your business on one platform, Simple, efficient, yet affordable

Check public demo: http://odoo.pigsty.cc, username: `test@pigsty.cc`, password: `pigsty`

If you want to access odoo through SSL, you have to trust `files/pki/ca/ca.crt` on your browser (or use the dirty hack `thisisunsafe` in chrome)


## Get Started

Check [`.env`](.env) file for configurable environment variables:

```bash
# https://hub.docker.com/_/odoo#
PG_HOST=10.10.10.10
PG_PORT=5432
PG_USER=dbuser_odoo
PG_PASS=DBUser.Odoo
ODOO_PORT=8069
```

Then launch odoo with:

```bash
make up  # docker compose up
```

Visit [http://ddl.pigsty](http://ddl.pigsty) or http://10.10.10.10:8887

## Makefile

```bash
make up         # pull up odoo with docker compose in minimal mode
make run        # launch odoo with docker , local data dir and external PostgreSQL
make view       # print odoo access point
make log        # tail -f odoo logs
make info       # introspect odoo with jq
make stop       # stop odoo container
make clean      # remove odoo container
make pull       # pull latest odoo image
make rmi        # remove odoo image
make save       # save odoo image to /tmp/docker/odoo.tgz
make load       # load odoo image from /tmp/docker/odoo.tgz
```

## Use External PostgreSQL

You can use external PostgreSQL for Odoo. Odoo will create its own database during setup, so you don't need to do that

```yaml
pg_users: [ { name: dbuser_odoo ,password: DBUser.Odoo ,pgbouncer: true ,roles: [ dbrole_admin ]    ,comment: admin user for odoo database } ]
pg_databases: [ { name: odoo ,owner: dbuser_odoo ,revokeconn: true ,comment: odoo primary database } ]
```

And create business user & database with:

```bash
bin/pgsql-user  pg-meta  dbuser_odoo
#bin/pgsql-db    pg-meta  odoo     # odoo will create the database during setup
```

Check connectivity:

```bash
psql postgres://dbuser_odoo:DBUser.Odoo@10.10.10.10:5432/odoo
```


## Expose Odoo Service

```yaml
    infra_portal:                     # domain names and upstream servers
      home         : { domain: h.pigsty }
      grafana      : { domain: g.pigsty    ,endpoint: "${admin_ip}:3000" , websocket: true }
      prometheus   : { domain: p.pigsty    ,endpoint: "${admin_ip}:9090" }
      alertmanager : { domain: a.pigsty    ,endpoint: "${admin_ip}:9093" }
      blackbox     : { endpoint: "${admin_ip}:9115" }
      loki         : { endpoint: "${admin_ip}:3100" }
      odoo         : { domain: odoo.pigsty, endpoint: "127.0.0.1:8069", websocket: true }  # <------ add this line
```

```bash
./infra.yml -t nginx   # setup nginx infra portal
```



# Odoo Addons

There are lots of Odoo modules available in the community, you can install them by downloading and placing them in the `addons` folder.

```yaml
volumes:
  - ./addons:/mnt/extra-addons
```

You can mount the `./addons` dir to the `/mnt/extra-addons` in the container, then download and unzip to the `addons` folder,

To enable addon module, first entering the [Developer mode](https://www.odoo.com/documentation/17.0/applications/general/developer_mode.html)

> Settings -> Generic Settings -> Developer Tools -> Activate the developer Mode

Then goes to the > Apps -> Update Apps List, then you can find the extra addons and install from the panel.

Frequently used [free](https://apps.odoo.com/apps/modules/browse?order=Downloads) addons: [Accounting Kit](https://apps.odoo.com/apps/modules/17.0/base_accounting_kit/)
