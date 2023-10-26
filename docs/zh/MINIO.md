# MINIO

> [Min.IO](https://min.io/docs/minio/linux/reference/minio-mc/mc-mb.html): S3兼容的开源多云对象存储。 [配置](#配置) | [管理](#管理) | [剧本](#剧本) | [监控](#监控) | [参数](#参数)

MinIO 是一个与 S3 兼容的对象存储服务，可以用来存储文档、图片、视频和备份。它支持原生的多节点多磁盘的高可用部署，可扩展、安全且易于使用。

Pigsty 中的 PGSQL 模块默认会使用本地 posix 文件系统存储备份，但您也可以选择使用 MinIO，或者外部的 S3 服务作为集中式的备份存储。
如果使用 MinIO 作为备份存储库，那么在部署 PGSQL 集群前应当首先初始化 MinIO 集群。

MinIO 模块需要安装在 Pigsty 纳管的节点上（也就是安装了 [`NODE`](NODE) 模块的节点），因为生产环境中的 MinIO 必须要使用 SSL 证书，所以会用到节点上的 CA。


----------------

## 配置

在部署之前，你需要定义一个 MinIO 集群。MinIO 有一些[参数](#参数)可以配置。

- [单机单盘](#单机单盘)
- [单机多盘](#单机多盘)
- [多机多盘](#多机多盘)
- [暴露服务](#暴露服务)
- [访问服务](#访问服务)
- [单机单盘](#暴露管控)



----------------

### 单机单盘

参考：[MinIO 单机单盘部署](https://min.io/docs/minio/linux/operations/install-deploy-manage/deploy-minio-single-node-single-drive.html)

定义一个单例 MinIO 实例非常简单直接：

```yaml
# 1 节点 1 驱动器（默认）
minio: { hosts: { 10.10.10.10: { minio_seq: 1 } }, vars: { minio_cluster: minio } }
```

The only required params are [`minio_seq`](PARAM#minio_seq) and [`minio_cluster`](PARAM#minio_cluster), which generate a unique identity for each MinIO instance. 

唯一需要的参数是 [`minio_seq`](PARAM#minio_seq) 和 [`minio_cluster`](PARAM#minio_cluster)，它们会唯一标识每一个 MinIO 实例。

单节点单驱动器模式仅用于开发目的，因此您可以使用一个普通的目录作为数据目录，该目录默认为 `/data/minio`。
请注意，在多盘或多节点模式下，如果使用普通目录作为数据目录而不是挂载点，MinIO 将拒绝启动。


----------------

### 单机多盘

参考：[MinIO 单机多盘部署](https://min.io/docs/minio/linux/operations/install-deploy-manage/deploy-minio-single-node-multi-drive.html)

要在单节点上使用多个磁盘，你需要以 `{{ prefix }}{x...y}` 的格式指定 [`minio_data`](PARAM#minio_data)，该格式定义了一系列磁盘挂载点。

```yaml
minio:
  hosts: { 10.10.10.10: { minio_seq: 1 } }
  vars:
    minio_cluster: minio         # minio 集群名称，默认为 minio
    minio_data: '/data{1...4}'   # minio 数据目录，使用 {x...y} 记号来指定多块磁盘
```

此示例定义了一个带有4个驱动器的单节点 MinIO 集群：`/data1`、`/data2`、`/data3` 和 `/data4`。启动 MinIO 之前，你需要正确地挂载它们：

```bash
mkfs.xfs /dev/sdb; mkdir /data1; mount -t xfs /dev/sdb /data1;   # 挂载第一块盘……
```

----------------

### 多机多盘

参考：[MinIO 多机多盘部署](https://min.io/docs/minio/linux/operations/install-deploy-manage/deploy-minio-multi-node-multi-drive.html)

MinIO 多节点部署需要用到一个额外的 [`minio_node`](PARAM#minio_node) 参数：

```yaml
minio:
  hosts:
    10.10.10.10: { minio_seq: 1 }
    10.10.10.11: { minio_seq: 2 }
    10.10.10.12: { minio_seq: 3 }
  vars:
    minio_cluster: minio
    minio_data: '/data{1...2}'                         # 每个节点使用两个磁盘
    minio_node: '${minio_cluster}-${minio_seq}.pigsty' # minio 节点名称规则
```

`${minio_cluster}` 和 `${minio_seq}` 将分别被替换为 [`minio_cluster`](PARAM#minio_cluster) 和 [`minio_seq`](PARAM#minio_seq) 的值，并用作 MinIO 节点名称。


----------------

### 暴露服务

MinIO 默认在端口 `9000` 上提供服务。如果您部署了多节点的 MinIO 集群，则可以通过任意一个节点来访问其服务。

您可以选择使用 keepalived 在 MinIO 集群上绑定一个 L2 [VIP](PARAM#node_vip)，或者使用由 [`NODE`](NODE) 模块的提供的 [`haproxy`](PARAM#haproxy) 组件，通过负载均衡器对外暴露 MinIO 服务。

下面是使用 HAProxy 对外暴露服务的一个例子：

```yaml
minio:
  hosts:
    10.10.10.10: { minio_seq: 1 , nodename: minio-1 }
    10.10.10.11: { minio_seq: 2 , nodename: minio-2 }
    10.10.10.12: { minio_seq: 3 , nodename: minio-3 }
  vars:
    minio_cluster: minio
    node_cluster: minio
    minio_data: '/data{1...2}'         # 每个节点两块磁盘
    minio_node: '${minio_cluster}-${minio_seq}.pigsty' # MinIO 节点名称规则
    haproxy_services:                  # 使用 HAPROXY 对外暴露 MinIO 服务
      - name: minio                    # [必选] 服务名称，集群内唯一
        port: 9002                     # [必选] 服务端口，集群内唯一
        options:                       # [可选] minio 健康检查
          - option httpchk
          - option http-keep-alive
          - http-check send meth OPTIONS uri /minio/health/live
          - http-check expect status 200
        servers:
          - { name: minio-1 ,ip: 10.10.10.10 ,port: 9000 ,options: 'check-ssl ca-file /etc/pki/ca.crt check port 9000' }
          - { name: minio-2 ,ip: 10.10.10.11 ,port: 9000 ,options: 'check-ssl ca-file /etc/pki/ca.crt check port 9000' }
          - { name: minio-3 ,ip: 10.10.10.12 ,port: 9000 ,options: 'check-ssl ca-file /etc/pki/ca.crt check port 9000' }
```

----------------

### 访问服务

如果您想要访问 [上面暴露的服务](#暴露服务)，可以修改 [`pgbackrest_repo`](PARAM#pgbackrest_repo) 中的配置，添加一个新的备份仓库定义： 

```yaml
# 这是新添加的 HA MinIO Repo 定义，使用此配置代替之前的单机 MinIO 配置
minio_ha:
  type: s3
  s3_endpoint: minio-1.pigsty   # s3_endpoint 可以是任何一个负载均衡器：10.10.10.1{0,1,2}，或指向任意 3 个节点的域名
  s3_region: us-east-1          # 你可以使用外部域名：sss.pigsty，该域名指向任一成员（`minio_domain`）
  s3_bucket: pgsql              # 你可使用实例名和节点名：minio-1.pigsty minio-1.pigsty minio-1.pigsty minio-1 minio-2 minio-3
  s3_key: pgbackrest            # 最好为 MinIO 的 pgbackrest 用户使用专门的密码
  s3_key_secret: S3User.SomeNewPassWord
  s3_uri_style: path
  path: /pgbackrest
  storage_port: 9002            # 使用负载均衡器的端口 9002 代替默认的 9000（直接访问）
  storage_ca_file: /etc/pki/ca.crt
  bundle: y
  cipher_type: aes-256-cbc      # 在您的生产环境中最好使用新的加密密码，这里可以使用集群名作为密码的一部分。
  cipher_pass: pgBackRest.With.Some.Extra.PassWord.And.Salt.${pg_cluster}
  retention_full_type: time
  retention_full: 14
```

----------------

### 暴露管控

MinIO 默认在端口 `9001` 上提供一个Web管控界面。

将管理界面暴露给外部不是明智的行为，如果你希望这样做，请将 MinIO 添加到 [`infra_portal`](PARAM#infra_portal) 并刷新 Nginx 配置。

```yaml
infra_portal:   # 域名和上游服务器定义
  # ...         # MinIO 管理页面需要 HTTPS / Websocket 才能工作
  minio1       : { domain: sss.pigsty  ,endpoint: 10.10.10.10:9001 ,scheme: https ,websocket: true }
  minio2       : { domain: sss2.pigsty ,endpoint: 10.10.10.11:9001 ,scheme: https ,websocket: true }
  minio3       : { domain: sss3.pigsty ,endpoint: 10.10.10.12:9001 ,scheme: https ,websocket: true }
```

查看 MinIO 示例[配置](https://github.com/Vonng/pigsty/blob/master/files/pigsty/minio.yml) 与专用的样例 [Vagrantfile](https://github.com/Vonng/pigsty/blob/master/vagrant/spec/minio.rb) 来获取更多信息。




----------------

## 管理

下面是 MinIO 模块中常用的管理命令，更多问题请参考 [FAQ：MINIO](FAQ#MINIO)。


### 创建集群

```bash
./minio.yml -l minio   # 在 'minio' 分组上完成 MINIO 集群初始化
```

----------------

### 客户端配置

要使用 `mcli` 客户端访问 `minio` 服务器集群，首先要配置服务器的别名（`alias`）：

```bash
mcli alias ls  # 列出 minio 别名（默认使用sss）
mcli alias set sss https://sss.pigsty:9000 minioadmin minioadmin              # root 用户
mcli alias set pgbackrest https://sss.pigsty:9000 pgbackrest S3User.Backup    # 备份用户
```

使用 `mcli` 可以管理 MinIO 中的业务用户，例如这里我们可以使用命令行创建两个业务用户：

```bash
mcli admin user list sss     # 列出 sss 上的所有用户
set +o history # 在历史记录中隐藏密码并创建 minio 用户
mcli admin user add sss dba S3User.DBA
mcli admin user add sss pgbackrest S3User.Backup
set -o history 
```

MinIO `mcli` 的完整功能参考，请查阅文档： [MinIO 客户端](https://min.io/docs/minio/linux/reference/minio-mc.html)。


----------------

### 增删改查

**您可以对MinIO中的存储桶进行增删改查**

```bash
mcli ls sss/                         # 列出别名 'sss' 的所有桶
mcli mb --ignore-existing sss/hello  # 创建名为 'hello' 的桶
mcli rb --force sss/hello            # 强制删除 'hello' 桶
```

**您也可以对存储桶内的对象进行增删改查**

```bash
mcli cp -r /www/pigsty/*.rpm sss/infra/repo/                # 将文件上传到前缀为 'repo' 的 'infra' 桶中
mcli cp sss/infra/repo/pg_exporter-0.5.0.x86_64.rpm /tmp/  # 从 minio 下载文件到本地
```





----------------

## 剧本

MinIO 模块提供了一个默认的剧本 [`minio.yml`](#minioyml) ，用于安装 MinIO 集群。但首先你需要[定义](#配置)它。

### `minio.yml`

剧本 [`minio.yml`](https://github.com/Vonng/pigsty/blob/master/minio.yml) 用于在节点上安装 MinIO 模块。

- `minio-id`        : 生成/校验 minio 身份参数
- `minio_os_user`   : 创建操作系统用户 minio
- `minio_install`   : 安装 minio/mcli 软件包
- `minio_clean`     : 移除 minio 数据目录 (默认不移除)
- `minio_dir`       : 创建 minio 目录
- `minio_config`    : 生成 minio 配置
  - `minio_conf`    : minio 主配置文件
  - `minio_cert`    : minio SSL证书签发
  - `minio_dns`     : minio DNS记录插入
- `minio_launch`    : minio 服务启动
- `minio_register`  : minio 纳入监控
- `minio_provision` : 创建 minio 别名/存储桶/业务用户
  - `minio_alias`   : 创建 minio 客户端别名（管理节点上）
  - `minio_bucket`  : 创建 minio 存储桶
  - `minio_user`    : 创建 minio 业务用户

[![asciicast](https://asciinema.org/a/566415.svg)](https://asciinema.org/a/566415)






----------------

## 监控

Pigsty 提供了两个与 [`MINIO`](MINIO) 模块有关的监控面板：

[MinIO Overview](https://demo.pigsty.cc/d/minio-overview) 展示了 MinIO 集群的整体监控指标。

[MinIO Instance](https://demo.pigsty.cc/d/minio-instance) 展示了单个 MinIO 实例的监控指标详情

[![minio-overview.jpg](https://repo.pigsty.cc/img/minio-overview.jpg)](https://demo.pigsty.cc/d/minio-overview)







----------------

## 参数

[MINIO](PARAM#minio) 模块有 15 个相关参数：

| 参数                                           |    类型    |  级别   | 注释                             |
|----------------------------------------------|:--------:|:-----:|--------------------------------|
| [`minio_seq`](PARAM#minio_seq)               |   int    |   I   | minio 实例标识符，必填                 |
| [`minio_cluster`](PARAM#minio_cluster)       |  string  |   C   | minio 集群名称，默认为 minio           |
| [`minio_clean`](PARAM#minio_clean)           |   bool   | G/C/A | 初始化时清除 minio？默认为 false         |
| [`minio_user`](PARAM#minio_user)             | username |   C   | minio 操作系统用户，默认为 `minio`       |
| [`minio_node`](PARAM#minio_node)             |  string  |   C   | minio 节点名模式                    |
| [`minio_data`](PARAM#minio_data)             |   path   |   C   | minio 数据目录，使用 `{x...y}` 指定多个磁盘 |
| [`minio_domain`](PARAM#minio_domain)         |  string  |   G   | minio 外部域名，默认为 `sss.pigsty`    |
| [`minio_port`](PARAM#minio_port)             |   port   |   C   | minio 服务端口，默认为 9000            |
| [`minio_admin_port`](PARAM#minio_admin_port) |   port   |   C   | minio 控制台端口，默认为 9001           |
| [`minio_access_key`](PARAM#minio_access_key) | username |   C   | 根访问密钥，默认为 `minioadmin`         |
| [`minio_secret_key`](PARAM#minio_secret_key) | password |   C   | 根密钥，默认为 `minioadmin`           |
| [`minio_extra_vars`](PARAM#minio_extra_vars) |  string  |   C   | minio 服务器的额外环境变量               |
| [`minio_alias`](PARAM#minio_alias)           |  string  |   G   | minio 部署的客户端别名                 |
| [`minio_buckets`](PARAM#minio_buckets)       | bucket[] |   C   | 待创建的 minio 存储桶列表               |
| [`minio_users`](PARAM#minio_users)           |  user[]  |   C   | 待创建的 minio 用户列表                |


```yaml
#minio_seq: 1                     # minio 实例标识符，必填
minio_cluster: minio              # minio 集群名称，默认为 minio
minio_clean: false                # 初始化时清除 minio？默认为 false
minio_user: minio                 # minio 操作系统用户，默认为 `minio`
minio_node: '${minio_cluster}-${minio_seq}.pigsty' # minio 节点名模式
minio_data: '/data/minio'         # minio 数据目录，使用 `{x...y}` 指定多个磁盘
minio_domain: sss.pigsty          # minio 外部域名，默认为 `sss.pigsty`
minio_port: 9000                  # minio 服务端口，默认为 9000
minio_admin_port: 9001            # minio 控制台端口，默认为 9001
minio_access_key: minioadmin      # 根访问密钥，默认为 `minioadmin`
minio_secret_key: minioadmin      # 根密钥，默认为 `minioadmin`
minio_extra_vars: ''              # minio 服务器的额外环境变量
minio_alias: sss                  # minio 部署的客户端别名
minio_buckets: [ { name: pgsql }, { name: infra },  { name: redis } ] # 待创建的 minio 存储桶列表
minio_users:                      # 待创建的 minio 用户列表
  - { access_key: dba , secret_key: S3User.DBA, policy: consoleAdmin }
  - { access_key: pgbackrest , secret_key: S3User.Backup, policy: readwrite }
```