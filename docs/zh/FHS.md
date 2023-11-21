# 文件结构

> 在 Pigsty 中， 文件是如何组织布局的？


----------------

## Pigsty FHS

Pigsty 的主目录默认放置于于 `~/pigsty`，该目录下的文件结构如下所示：

```bash
#------------------------------------------------------------------------------
# pigsty
#  ^-----@app                    # 额外的示例应用资源
#  ^-----@bin                    # bin 脚本
#  ^-----@docs                   # 文档（可docsify化）
#  ^-----@files                  # ansible 文件资源
#            ^-----@pigsty       # pigsty 配置模板文件
#            ^-----@prometheus   # prometheus 规则定义
#            ^-----@grafana      # grafana 仪表盘
#            ^-----@postgres     # /pg/bin/ 脚本
#            ^-----@migration    # pgsql 迁移任务定义
#            ^-----@pki          # 自签名 CA 和证书
#  ^-----@roles                  # ansible 剧本实现
#  ^-----@templates              # ansible 模板文件
#  ^-----@vagrant                # Vagrant 沙箱虚拟机定义模板
#  ^-----@terraform              # Terraform 云虚拟机申请模板
#  ^-----configure               # 配置向导脚本
#  ^-----ansible.cfg             # ansible 默认配置文件
#  ^-----pigsty.yml              # pigsty 默认配置文件
#  ^-----*.yml                   # ansible 剧本
#------------------------------------------------------------------------------
# /etc/pigsty/
#  ^-----@targets                # 基于文件的服务发现目标定义
#  ^-----@dashboards             # grafana 监控面板
#  ^-----@datasources            # grafana 数据源
#  ^-----@playbooks              # ansible 剧本
#------------------------------------------------------------------------------
```



----------------

## CA FHS

Pigsty 的自签名 CA 位于 Pigsty 主目录下的 `files/pki/`。

**你必须妥善保管 CA 的密钥文件**：`files/pki/ca/ca.key`，该密钥是在 `install.yml` 或 `infra.yml` 的 `ca` 角色负责生成的。



```bash
# pigsty/files/pki
#  ^-----@ca                      # 自签名 CA 密钥和证书
#         ^-----@ca.key           # 非常重要：保守其秘密
#         ^-----@ca.crt           # 非常重要：在所有地方都受信任
#  ^-----@csr                     # 签名请求 csr
#  ^-----@misc                    # 杂项证书，已签发证书
#  ^-----@etcd                    # etcd 服务器证书
#  ^-----@minio                   # minio 服务器证书
#  ^-----@nginx                   # nginx SSL 证书
#  ^-----@infra                   # infra 客户端证书
#  ^-----@pgsql                   # pgsql 服务器证书
#  ^-----@mongo                   # mongodb/ferretdb 服务器证书
#  ^-----@mysql                   # mysql 服务器证书（占位符）
```

被 Pigsty 所管理的节点将安装以下证书文件：

```
/etc/pki/ca.crt                             # 所有节点都添加的根证书
/etc/pki/ca-trust/source/anchors/ca.crt     # 软链接到系统受信任的锚点
```

所有 infra 节点都会有以下证书：

```
/etc/pki/infra.crt                          # infra 节点证书
/etc/pki/infra.key                          # infra 节点密钥
```

当您的管理节点出现故障时，`files/pki` 目录与 `pigsty.yml` 文件应当在备份的管理节点上可用。你可以用 `rsync` 做到这一点。

```bash
# run on meta-1, rsync to meta2
cd ~/pigsty;
rsync -avz ./ meta-2:~/pigsty  
```




----------------

## NODE FHS

节点的数据目录由参数 [`node_data`](PARAM#node_data) 指定，默认为 `/data`，由 `root` 用户持有，权限为 `0777`。

每个组件的默认数据目录都位于这个数据库目录下，如下所示：

```bash
/data
#  ^-----@postgres                   # postgres 数据库目录
#  ^-----@backups                    # postgres 备份数据目录（没有专用备份盘时）
#  ^-----@redis                      # redis 数据目录（多实例共用）
#  ^-----@minio                      # minio 数据目录（单机单盘模式）
#  ^-----@etcd                       # etcd 主数据目录
#  ^-----@prometheus                 # prometheus 监控时序数据目录
#  ^-----@loki                       # Loki 日志数据目录
#  ^-----@docker                     # Docker数据目录
#  ^-----@...                        # 其他组件的数据目录
```



----------------

## Prometheus FHS

Prometheus 的主配置文件则位于 [`roles/infra/templates/prometheus/prometheus.yml.j2`](https://github.com/Vonng/pigsty/blob/master/roles/infra/templates/prometheus/prometheus.yml.j2) ，并渲染至所有基础设施节点的 `/etc/prometheus/prometheus.yml`。

Prometheus 相关的脚本与规则定义放置于 pigsty 主目录下的 [`files/prometheus/`](https://github.com/Vonng/pigsty/tree/master/files/prometheus) 目录，会被拷贝至所有基础设施节点的 `/etc/prometheus/` 下。

```bash
# /etc/prometheus/
#  ^-----prometheus.yml              # Prometheus 主配置文件
#  ^-----@bin                        # 工具脚本：检查配置，显示状态，重载配置，重建集群
#  ^-----@rules                      # 记录和报警规则定义
#            ^-----agent.yml         # agnet 规则和报警
#            ^-----infra.yml         # infra 规则和报警
#            ^-----etcd.yml          # etcd 规则和报警
#            ^-----node.yml          # node  规则和报警
#            ^-----pgsql.yml         # pgsql 规则和报警
#            ^-----redis.yml         # redis 规则和报警
#            ^-----minio.yml         # minio 规则和报警
#            ^-----mysql.yml         # mysql 规则和报警（占位）
#  ^-----@targets                    # 基于文件的服务发现目标定义
#            ^-----@infra            # infra 静态目标定义
#            ^-----@node             # node  静态目标定义
#            ^-----@pgsql            # pgsql 静态目标定义
#            ^-----@pgrds            # pgsql 远程RDS目标
#            ^-----@redis            # redis 静态目标定义
#            ^-----@minio            # minio 静态目标定义
#            ^-----@mongo            # mongo 静态目标定义
#            ^-----@mysql            # mysql 静态目标定义
#            ^-----@etcd             # etcd 静态目标定义
#            ^-----@ping             # ping 静态目标定义
#            ^-----@patroni          # patroni 静态目标定义 （当patroni启用SSL时使用此目录）
#            ^-----@.....            # 其他监控目标定义
# /etc/alertmanager.yml              # 告警组件主配置文件
# /etc/blackbox.yml                  # 黑盒探测主配置文件

```



----------------

## Postgres FHS


以下参数与PostgreSQL数据库目录结构相关:

* [pg_dbsu_home](PARAM#pg_dbsu_home)： Postgres 默认用户的家目录，默认为`/var/lib/pgsql`
* [pg_bin_dir](PARAM#pg_bin_dir)： Postgres二进制目录，默认为`/usr/pgsql/bin/`
* [pg_data](PARAM#pg_data)：Postgres数据库目录，默认为`/pg/data`
* [pg_fs_main](PARAM#pg_fs_main)：Postgres主数据盘挂载点，默认为`/data`
* [pg_fs_bkup](PARAM#pg_fs_bkup)：Postgres备份盘挂载点，默认为`/var/backups`（可选，也可以选择备份到主数据盘上的子目录）


```yaml
# 工作假设:
#   {{ pg_fs_main }} 主数据目录，默认位置：`/data`          [快速SSD]
#   {{ pg_fs_bkup }} 备份数据盘，默认位置：`/data/backups`  [廉价HDD]
#--------------------------------------------------------------#
# 默认配置:
#     pg_fs_main = /data             高速SSD
#     pg_fs_bkup = /data/backups     廉价HDD (可选)
#
#     /pg      -> /data/postgres/pg-test-15    (软链接)
#     /pg/data -> /data/postgres/pg-test-15/data
#--------------------------------------------------------------#
- name: create postgresql directories
  tags: pg_dir
  become: yes
  block:

    - name: make main and backup data dir
      file: path={{ item }} state=directory owner=root mode=0777
      with_items:
        - "{{ pg_fs_main }}"
        - "{{ pg_fs_bkup }}"

    # pg_cluster_dir:    "{{ pg_fs_main }}/postgres/{{ pg_cluster }}-{{ pg_version }}"
    - name: create postgres directories
      file: path={{ item }} state=directory owner={{ pg_dbsu }} group=postgres mode=0700
      with_items:
        - "{{ pg_fs_main }}/postgres"
        - "{{ pg_cluster_dir }}"
        - "{{ pg_cluster_dir }}/bin"
        - "{{ pg_cluster_dir }}/log"
        - "{{ pg_cluster_dir }}/tmp"
        - "{{ pg_cluster_dir }}/cert"
        - "{{ pg_cluster_dir }}/conf"
        - "{{ pg_cluster_dir }}/data"
        - "{{ pg_cluster_dir }}/meta"
        - "{{ pg_cluster_dir }}/stat"
        - "{{ pg_cluster_dir }}/change"
        - "{{ pg_backup_dir }}/backup"
```


**数据文件结构**

```bash
# 真实目录
{{ pg_fs_main }}     /data                      # 顶层数据目录，通常为高速SSD挂载点
{{ pg_dir_main }}    /data/postgres             # 包含所有 Postgres 实例的数据目录（可能有多个实例/不同版本）
{{ pg_cluster_dir }} /data/postgres/pg-test-15  # 包含了 `pg-test` 集群的数据 (大版本是15)
                     /data/postgres/pg-test-15/bin            # 关于 PostgreSQL 的实用脚本
                     /data/postgres/pg-test-15/log            # 日志：postgres/pgbouncer/patroni/pgbackrest
                     /data/postgres/pg-test-15/tmp            # 临时文件，例如渲染出的 SQL 文件
                     /data/postgres/pg-test-15/cert           # postgres 服务器证书
                     /data/postgres/pg-test-15/conf           # postgres 相关配置文件索引
                     /data/postgres/pg-test-15/data           # postgres 主数据目录
                     /data/postgres/pg-test-15/meta           # postgres 身份信息
                     /data/postgres/pg-test-15/stat           # 统计信息，日志报表，汇总摘要
                     /data/postgres/pg-test-15/change         # 变更记录
                     /data/postgres/pg-test-15/backup         # 指向备份目录的软链接。

{{ pg_fs_bkup }}     /data/backups                            # 可选的备份盘目录/挂载点
                     /data/backups/postgres/pg-test-15/backup # 集群备份的实际存储位置

# 软链接
/pg             ->   /data/postgres/pg-test-15                # pg 根软链接
/pg/data        ->   /data/postgres/pg-test-15/data           # pg 数据目录
/pg/backup      ->   /var/backups/postgres/pg-test-15/backup  # pg 备份目录
```



**二进制文件结构**

在 EL 兼容发行版上（使用yum），PostgreSQL 默认安装位置为

```bash
/usr/pgsql-${pg_version}/
```

Pigsty 会创建一个名为 `/usr/pgsql` 的软连接，指向由 [`pg_version`](PARAM#pg_version) 参数指定的实际版本，例如

```bash
/usr/pgsql -> /usr/pgsql-15
```

因此，默认的 [`pg_bin_dir`](PARAM#pg_bin_dir) 是 `/usr/pgsql/bin/`，而该路径会被添加至系统的 `PATH` 环境变量中，定义文件为：`/etc/profile.d/pgsql.sh`.

```bash
export PATH="/usr/pgsql/bin:/pg/bin:$PATH"
export PGHOME=/usr/pgsql
export PGDATA=/pg/data
```

在 Ubuntu/Debian 上，PostgreSQL Deb 包的默认安装位置是：

```bash
/usr/lib/postgresql/${pg_version}/bin
```



----------------

## Pgbouncer FHS

Pgbouncer 使用与 `{{ pg_dbsu }}` （默认为 `postgres`） 相同的用户运行，配置文件位于`/etc/pgbouncer`。

* `pgbouncer.ini`，连接池主配置文件
* `database.txt`：定义连接池中的数据库
* `userlist.txt`：定义连接池中的用户
* `pgb_hba.conf`：定义连接池的访问权限




----------------

## Redis FHS

Pigsty提供了对Redis部署与监控对基础支持。

Redis二进制使用RPM包或复制二进制的方式安装于`/bin/`中，包括

```bash
redis-server    
redis-server    
redis-cli       
redis-sentinel  
redis-check-rdb 
redis-check-aof 
redis-benchmark 
/usr/libexec/redis-shutdown
```

对于一个名为 `redis-test-1-6379` 的 Redis 实例，与其相关的资源如下所示：

```bash
/usr/lib/systemd/system/redis-test-1-6379.service               # 服务 (在Debian系中为/lib/systemd)
/etc/redis/redis-test-1-6379.conf                               # 配置 
/data/redis/redis-test-1-6379                                   # 数据库目录
/data/redis/redis-test-1-6379/redis-test-1-6379.rdb             # RDB文件
/data/redis/redis-test-1-6379/redis-test-1-6379.aof             # AOF文件
/var/log/redis/redis-test-1-6379.log                            # 日志
/var/run/redis/redis-test-1-6379.pid                            # PID
```

对于 Ubuntu / Debian 而言，systemd 服务的默认目录不是 `/usr/lib/systemd/system/` 而是 `/lib/systemd/system/`

