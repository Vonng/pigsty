# 容器指南

Pigsty v1.4.1 带有Docker与Docker Compose部署支持，其中，Docker Daemon将默认在元节点上启用，以供安装更多SaaS服务

您可以使用Docker，快速部署启动软件应用，在容器中，您可以直接使用连接串访问部署于宿主机上的PostgreSQL/Redis数据库。

* [PgAdmin4](#PG管理工具：PgAdmin) ： 一个用于管理PostgreSQL数据库实例的GUI工具
* [PGWeb](#PGWeb客户端工具)：一个自动根据PG数据库模式生成后端API服务的工具
* [PostgREST](#自动后端API：PostgREST)：一个自动根据PG数据库模式生成后端API服务的工具
* [ByteBase](#模式迁移工具：ByteBase) ： 一个用于进行PostgreSQL模式变更的GUI工具
* [Jupyter Lab](#数据分析环境：Jupyter)：一个开箱即用的数据分析与处理Python实验环境

您也可以使用Docker执行一些随用随抛的命令工具，例如：

* [SchemaSPY](#数据库模式报表SchemaSPY)：生成数据库模式的详细可视化报表
* [Pgbadger](#数据库日志报表)：生成数据库日志报表

您也可以用Docker拉起一些开箱即用的开源SaaS服务：

* [Gitlab](#Gitlab)：开源代码托管平台。
* [Habour](#Habour)：开源镜像仓库
* [Jira](#Jira)：开源项目管理平台。
* [Confluence](#Confluence)：开源知识托管平台。
* [Odoo](#Odoo)：开源ERP
* [Mastodon](#Mastodon)：基于PG的社交网络
* [Discourse](#Discourse)：基于PG与Redis的开源论坛




## 向Nginx添加新服务

本文介绍的大部分软件均对外提供Web界面，尽管您可以直接通过IP:Port的方式访问，但我们依然建议收敛访问入口，使用域名并统一从Nginx代理访问。使用以下配置与命令，向Nginx注册新的服务。

```bash
# 添加新的Nginx服务定义
nginx_upstreams:
  - { name: pgadmin,     domain: pgadmin.pigsty,     endpoint: "10.10.10.10:8080" }
  - { name: pgweb,       domain: pgweb.pigsty,       endpoint: "10.10.10.10:8081" }
  - { name: postgrest,   domain: api.pigsty,         endpoint: "10.10.10.10:8082" }
  - { name: bytebase,    domain: bytebase.pigsty,    endpoint: "10.10.10.10:8083" }
  - { name: jupyter,     domain: lab.pigsty,         endpoint: "10.10.10.10:8084" }
  - { name: matrixdb,    domain: matrix.pigsty,      endpoint: "10.10.10.10:8420" }
  
./infra.yml -t nginx_config,nginx_restart    # 重新生成Nginx配置文件，并重启生效
```


## PG管理工具：PgAdmin

[PGAdmin4](https://www.pgadmin.org/)是流行的PG管控工具，使用以下命令，在元节点上拉起PgAdmin4服务，默认为主机`8080`端口，用户名 `admin@pigsty.cc`，密码：`pigsty`

```bash
docker run --init --name pgadmin --restart always --detach --publish 8080:80 \
    -e PGADMIN_DEFAULT_EMAIL=admin@pigsty.cc -e PGADMIN_DEFAULT_PASSWORD=pigsty dpage/pgadmin4
```

常用操作：将服务器访问信息复制至 /tmp/servers.json 文件中，并重新导入。

```bash
# 导出 pgadmin4 服务器列表
docker exec -it pgadmin /venv/bin/python3 /pgadmin4/setup.py --user admin@pigsty.cc --dump-servers /tmp/servers.json
docker cp pgadmin:/tmp/servers.json /tmp/servers.json

# 从 /tmp/servers.json 文件导入 PGADMIN
docker cp /tmp/servers.json pgadmin:/tmp/servers.json
docker exec -it pgadmin /venv/bin/python3 /pgadmin4/setup.py --user admin@pigsty.cc --load-servers /tmp/servers.json
```




## PGWeb客户端工具

[PGWeb](https://github.com/sosedoff/pgweb)是一款基于浏览器的PG客户端工具，使用以下命令，在元节点上拉起PGWEB服务，默认为主机`8081`端口。

```bash
# docker stop pgweb; docker rm pgweb
docker run --init --name pgweb --restart always --detach --publish 8081:8081 sosedoff/pgweb 
```

用户需要自行填写数据库连接串，例如默认CMDB的：`postgres://dbuser_dba:DBUser.DBA@p1staff.com`。





## 自动后端API：PostgREST

[PostgREST](https://postgrest.org/en/stable/index.html)是一个自动根据 PostgreSQL 数据库模式生成 REST API的二进制组件。

例如，以下命令将使用docker拉起 postgrest （本地 8082 端口，使用默认管理员用户，暴露Pigsty CMDB模式）

```bash
docker run --init --name postgrest --restart always --detach --net=host -p 8082:8082 \
  -e PGRST_DB_URI="postgres://dbuser_dba:DBUser.DBA@10.10.10.10/meta" -e PGRST_DB_SCHEMA="pigsty" -e PGRST_DB_ANON_ROLE="dbuser_dba" -e PGRST_SERVER_PORT=8082 -e PGRST_JWT_SECRET=haha \
  postgrest/postgrest
```

访问 http://10.10.10.10:8082 会展示所有自动生成API的定义，在 [Swagger Editor](https://editor.swagger.io) 中可以自动生成API文档。

`curl http://10.10.10.10:8082/cluster` 会匿名访问数据表`pigsty.cluster`。

如果您想要进行增删改查，设计更精细的权限控制，请参考 [Tutorial 1 - The Golden Key](https://postgrest.org/en/stable/tutorials/tut1.html)，生成一个签名JWT。



## 模式迁移工具：ByteBase

[ByteBase](https://bytebase.com/)是一个进行数据库模式变更的工具，以下命令将在元节点 8083 端口启动一个ByteBase。

```bash
docker run --init --name bytebase --restart always --detach --publish 8083:8083 --volume ~/.bytebase/data:/var/opt/bytebase \
    bytebase/bytebase:1.0.4 --data /var/opt/bytebase --host http://bytebase.pigsty --port 8083
```

访问 http://10.10.10.10:8083/ 即可使用 ByteBase，您需要依次创建项目、环境、实例、数据库，即可开始进行模式变更。




## 数据分析环境：Jupyter

[Jupyter Lab](https://github.com/jupyter/docker-stacks) 是一站式数据分析环境，下列命令将在 8084 端口启动一个Jupyter Server.

```bash
docker run -it --restart always --detach --name jupyter -p 8083:8888 -v "${PWD}":/tmp/notebook jupyter/scipy-notebook
docker logs jupyter # 打印日志，获取登陆的Token
```

访问 http://10.10.10.10:8084/ 即可使用 JupyterLab，（需要填入自动生成的Token）. 注意，Pigsty在宿主机上也安装有JupyterLab。



## 样例：数据库模式报表SchemaSPY

使用以下`docker`生成数据库模式报表，以CMDB为例：

```bash
docker run -v /www/schema/pg-meta/meta/pigsty:/output andrewjones/schemaspy-postgres:latest \
    -host 10.10.10.10 -port 5432 -u dbuser_dba -p DBUser.DBA -db meta -s pigsty
```

然后访问 http://pigsty/schema/pg-meta/meta/pigsty 即可访问Schema报表






## 样例：开源代码仓库：Gitlab

请参考[Gitlab Docker部署文档](https://docs.gitlab.com/ee/install/docker.html) 完成Docker部署。

```bash
export GITLAB_HOME=/data/gitlab

sudo docker run --detach \
  --hostname gitlab.example.com \
  --publish 443:443 --publish 80:80 --publish 23:22 \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  --shm-size 256m \
  gitlab/gitlab-ee:latest
  
sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
```



## 样例：开源技术论坛：Discourse

搭建开源论坛Discourse，需要调整配置 `app.yml` ，重点是SMTP部分的配置

<details><summary>Discourse配置样例</summary>

```yaml
templates:
  - "templates/web.china.template.yml"
  - "templates/postgres.template.yml"
  - "templates/redis.template.yml"
  - "templates/web.template.yml"
  - "templates/web.ratelimited.template.yml"
## Uncomment these two lines if you wish to add Lets Encrypt (https)
# - "templates/web.ssl.template.yml"
# - "templates/web.letsencrypt.ssl.template.yml"
expose:
  - "80:80"   # http
  - "443:443" # https
params:
  db_default_text_search_config: "pg_catalog.english"
  db_shared_buffers: "768MB"
env:
  LC_ALL: en_US.UTF-8
  LANG: en_US.UTF-8
  LANGUAGE: en_US.UTF-8
  EMBER_CLI_PROD_ASSETS: 1
  UNICORN_WORKERS: 4
  DISCOURSE_HOSTNAME: forum.pigsty
  DISCOURSE_DEVELOPER_EMAILS: 'fengruohang@outlook.com,rh@vonng.com'
  DISCOURSE_SMTP_ENABLE_START_TLS: false
  DISCOURSE_SMTP_AUTHENTICATION: login
  DISCOURSE_SMTP_OPENSSL_VERIFY_MODE: none
  DISCOURSE_SMTP_ADDRESS: smtpdm.server.address
  DISCOURSE_SMTP_PORT: 80
  DISCOURSE_SMTP_USER_NAME: no_reply@mail.pigsty.cc
  DISCOURSE_SMTP_PASSWORD: "<password>"
  DISCOURSE_SMTP_DOMAIN: mail.pigsty.cc
volumes:
  - volume:
      host: /var/discourse/shared/standalone
      guest: /shared
  - volume:
      host: /var/discourse/shared/standalone/log/var-log
      guest: /var/log

hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/discourse/docker_manager.git
run:
  - exec: echo "Beginning of custom commands"
  # - exec: rails r "SiteSetting.notification_email='no_reply@mail.pigsty.cc'"
  - exec: echo "End of custom commands"
```

</details>

然后，执行以下命令，拉起Discourse即可。

```sql
./launcher rebuild app
```


## 样例：开源社交网站：Mastodon









