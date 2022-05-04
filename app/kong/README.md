# PGWEB


## TL;DR

```bash
cd app/kong
docker-compose up -d
```

## Scripts

* Default Port: 8000
* Default SSL Port: 8443
* Default Admin Port: 8001
* Default Postgres Database: `postgres://dbuser_kong:DBUser.Kong@10.10.10.10:5432/kong` 

```yaml
# postgres://dbuser_kong:DBUser.Kong@10.10.10.10:5432/kong
- { name: kong, owner: dbuser_kong, revokeconn: true , comment: kong the api gateway database }
- { name: dbuser_kong, password: DBUser.Kong , pgbouncer: true , roles: [ dbrole_admin ], comment: admin user for kong database }
```