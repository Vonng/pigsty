# 容器指南

Pigsty v1.5 带有Docker与Kubernetes部署支持，其中，Docker Daemon将默认在管理节点上启用，以供安装更多SaaS服务

您可以使用Docker，快速部署启动软件应用，在容器中，您可以直接使用连接串访问部署于宿主机上的PostgreSQL/Redis数据库。


## 样例：模式迁移工具：ByteBase

```bash
docker run \
    --init --name bytebase \
    --restart always \
    --detach \
    --add-host host.docker.internal:host-gateway \
    --publish 8080:8080 --volume ~/.bytebase/data:/var/opt/bytebase \
    bytebase/bytebase:1.0.2 --data /var/opt/bytebase --host http://localhost --port 8080
```

例如，上述命令将在8080端口启动一个ByteBase，可用于数据库模式迁移。

```bash
# 添加新的Nginx服务，然后更新配置
nginx_upstreams:
  - { name: bb,       domain: bb.pigsty, endpoint: "10.10.10.10:8080" }

./infra.yml -t nginx_config
ssh meta 'sudo nginx -s reload'

# 在您本地添加解析 /etc/hosts
10.10.10.10 bb.pigsty
```



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



## 样例：自动的后端API：PostgREST

[PostgREST](https://postgrest.org/en/stable/index.html)是一个自动根据 PostgreSQL 数据库模式生成 REST API的二进制组件。

例如，以下命令将使用docker拉起 postgrest （本地8123端口，使用默认管理员用户，暴露Pigsty CMDB模式）

```bash
docker run --rm --net=host -p 8123:8123 \
  -e PGRST_DB_URI="postgres://dbuser_dba:DBUser.DBA@10.10.10.10/meta" \
  -e PGRST_DB_SCHEMA="pigsty" \
  -e PGRST_DB_ANON_ROLE="dbuser_dba" \
  -e PGRST_SERVER_PORT=8123 \
  -e PGRST_JWT_SECRET=haha \
  postgrest/postgrest
```

访问 http://10.10.10.10:8123 会展示所有自动生成API的定义，在 [Swagger Editor](https://editor.swagger.io) 中可以自动生成API文档。

`curl http://10.10.10.10:8123/cluster` 会匿名访问数据表`pigsty.cluster`。

如果您想要进行增删改查，设计更精细的权限控制，请参考 [Tutorial 1 - The Golden Key](https://postgrest.org/en/stable/tutorials/tut1.html)，生成一个签名JWT。



## 样例：数据库模式报表SchemaSPY

使用以下`docker`生成数据库模式报表，以CMDB为例：

```bash
docker run -v /www/schema/pg-meta/meta/pigsty:/output \
    andrewjones/schemaspy-postgres:latest \
    -host 10.10.10.10 -port 5432 -u dbuser_dba -p DBUser.DBA -db meta -s pigsty
```

然后访问 http://pigsty/schema/pg-meta/meta/pigsty 即可访问Schema报表



