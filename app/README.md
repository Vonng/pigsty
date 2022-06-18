# App

You can run ton's of software based on pigsty database & docker runtime.


## Built-in Application

* [PgAdmin4](pgadmin/) : Postgres Admin UI
* [PgWeb](pgweb/) : Postgres WEBConsole
* [ByteBase](bytebase/) : DDL Migration
* [PostgREST](postgrest/) : Auto-PG REST API
* [Kong](kong/) : The API Gateway
* [Gitea](gitea/) : Git hosting services 

**Access Point**

```yaml
{ name: postgrest , domain: api.pigsty.cc  , endpoint: "127.0.0.1:8884" }
{ name: pgadmin   , domain: adm.pigsty.cc  , endpoint: "127.0.0.1:8885" }
{ name: pgweb     , domain: cli.pigsty.cc  , endpoint: "127.0.0.1:8886" }
{ name: bytebase  , domain: ddl.pigsty.cc  , endpoint: "127.0.0.1:8887" }
{ name: jupyter   , domain: lab.pigsty.cc  , endpoint: "127.0.0.1:8888" }
{ name: gitea     , domain: git.pigsty.cc  , endpoint: "127.0.0.1:8889" }
{ name: minio     , domain: sss.pigsty.cc  , endpoint: "127.0.0.1:9000" }
```

**Pull Image**

```bash
docker pull kong                      # latest # 139MB
docker pull minio/minio               # latest # 227MB
docker pull alpine                    # latest # 5.57MB
docker pull registry                  # latest # 24.2MB
docker pull dpage/pgadmin4            # latest # 341MB
docker pull sosedoff/pgweb            # latest # 192MB
docker pull vonng/pg_exporter         # latest # 7.64B
docker pull postgrest/postgrest       # latest # 16.3MB
docker pull swaggerapi/swagger-ui     # latest # 77MB
docker pull bytebase/bytebase:1.1.1   # 1.1.1  # 78.1MB
docker pull ghcr.io/ferretdb/ferretdb # latest # 18.1MB

docker pull gitea/gitea              # latest # 256MB
docker pull requarks/wiki:2          # 2 444 MB
docker pull andrewjones/schemaspy-postgres # latest
```

**Make Cache**

```bash
# make image cache
docker save kong alpine registry dpage/pgadmin4 sosedoff/pgweb vonng/pg_exporter postgrest/postgrest swaggerapi/swagger-ui minio/minio bytebase/bytebase:1.1.1  ghcr.io/ferretdb/ferretdb | gzip -9 -c > /tmp/docker.tgz
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
docker save odoo quay.io/keycloak/keycloak tootsuite/mastodon cptactionhank/atlassian-confluence cptactionhank/atlassian-jira-software jupyter/scipy-notebook gitlab/gitlab-ee grafana/grafana-oss | gzip -c - > software.tar.lz4
cat software.tar.lz4 | gzip -d -c - | docker load  
```


## Visualization App

Check [pigsty-app](https://github.com/Vonng/pigsty-app) for details.

Pigsty has one embed visualization app: [pglog](http://demo.pigsty.cc/d/pglog-overview) which is used for pg csv log analysis.
