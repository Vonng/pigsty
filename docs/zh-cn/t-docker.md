# 容器指南

Pigsty v1.5.0 带有Docker与Docker Compose部署支持，其中，Docker Daemon将默认在元节点上启用，以供安装更多SaaS服务

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
nginx_upstreams:
  - { name: kong         , domain: api.pigsty , endpoint: "127.0.0.1:8880"   } #== v optional ==#
  - { name: pgadmin      , domain: adm.pigsty , endpoint: "127.0.0.1:8885"   }
  - { name: pgweb        , domain: cli.pigsty , endpoint: "127.0.0.1:8886"   }
  - { name: bytebase     , domain: ddl.pigsty , endpoint: "127.0.0.1:8887"   }
  - { name: jupyter      , domain: lab.pigsty , endpoint: "127.0.0.1:8888"   }

./infra.yml -t nginx_config,nginx_restart    # 重新生成Nginx配置文件，并重启生效
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







