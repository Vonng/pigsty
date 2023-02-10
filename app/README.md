# App

Here are some docker compose templates for popular applications that works well with PostgreSQL

* [PgAdmin4](pgadmin/) : Postgres Admin Tools
* [PgWeb](pgweb/) : Postgres Web Console
* [ByteBase](bytebase/) : Postgres DDL Migration
* [PostgREST](postgrest/) : Auto-Generated PG Backend REST API
* [Kong](kong/) : Kong API Gateway
* [Gitea](gitea/) : Self-Hosting Git Services
* [Wiki](wiki/) : Local Wiki Service
* [FerretDB](ferretdb/) : MongoDB API over Postgres
* [EdgeDB](edgedb): Graph database based on Postgres
* SupaBase...


**Portals**

There are several predefined portals

```yaml
postgrest : { domain: api.pigsty  ,endpoint: "127.0.0.1:8884"   }
pgadmin   : { domain: adm.pigsty  ,endpoint: "127.0.0.1:8885"   }
pgweb     : { domain: cli.pigsty  ,endpoint: "127.0.0.1:8886"   }
bytebase  : { domain: ddl.pigsty  ,endpoint: "127.0.0.1:8887"   }
jupyter   : { domain: lab.pigsty  ,endpoint: "127.0.0.1:8888"   }
gitea     : { domain: git.pigsty  ,endpoint: "127.0.0.1:8889"   }
minio     : { domain: sss.pigsty  ,endpoint: "127.0.0.1:9000"   }
wiki      : { domain: wiki.pigsty ,endpoint: "127.0.0.1:9002"   }
```

**Pull Image**

```bash
docker pull kong                      # 164MB
docker pull alpine                    # 7MB
docker pull registry                  # 24.2MB
docker pull dpage/pgadmin4            # 341MB
docker pull sosedoff/pgweb            # 192MB
docker pull vonng/pg_exporter         # 7.64B
docker pull postgrest/postgrest       # 16.3MB
docker pull swaggerapi/swagger-ui     # 77MB
docker pull bytebase/bytebase:1.12.0  # 287MB
docker pull ghcr.io/ferretdb/ferretdb # 18.1MB

docker pull gitea/gitea               # latest # 256MB
docker pull requarks/wiki             # latest 444 MB
docker pull andrewjones/schemaspy-postgres # latest 
```


**Make Cache**

```bash
# make image cache
docker save kong alpine registry dpage/pgadmin4 sosedoff/pgweb vonng/pg_exporter postgrest/postgrest bytebase/bytebase:1.12.0  | gzip -9 -c > /tmp/docker.tgz
cat /tmp/docker.tgz | gzip -d -c - | docker load  
```


## Software

There are lots of software using PostgreSQL / Redis.

* KeyCloak : SSO Solution
* Gitlab : Code Management
* Odoo : CRM/ERP
* Jira : Project Management
* Confluence: Document Management
* Harbour : Image Management
* JupyterLab : Data Analysis
* Grafana : Data Visualization
* Mastodon : Social Network
* Discourse : Community

```bash
docker pull odoo                                        # latest   # 1.49GB
docker pull quay.io/keycloak/keycloak:18.0.0            # 18.0.0   # 562MB
docker pull tootsuite/mastodon                          # latest   # 1.76GB
docker pull cptactionhank/atlassian-confluence:7.7.3    # 7.7.3    # 835MB
docker pull cptactionhank/atlassian-jira-software:8.1.0 # 8.1.0    # 531MB
docker pull jupyter/scipy-notebook                      # latest   # 3.01GB
docker pull gitlab/gitlab-ee                            # latest   # 2.69GB
docker pull grafana/grafana-oss                         # latest   # 286MB
```

**Make Cache for Software**

```bash
docker save odoo quay.io/keycloak/keycloak tootsuite/mastodon cptactionhank/atlassian-confluence cptactionhank/atlassian-jira-software jupyter/scipy-notebook gitlab/gitlab-ee grafana/grafana-oss | gzip -c - > docker.tgz
cat /tmp/docker.tgz | gzip -d -c - | docker load  
```


## Visualization App

Check [pigsty-app](https://github.com/Vonng/pigsty-app) for details.

Pigsty has one embed visualization app: [pglog](http://demo.pigsty.cc/d/pglog-overview) which is used for pg csv log analysis.
