# 安全考量

> Pigsty 的默认配置已经足以覆盖绝大多数场景对于安全的需求。

Pigsty 已经提供了开箱即用的[认证](PGSQL-HBA)与[访问控制](PGSQL-ACL)模型，对于绝大多数场景已经足够安全。

[![pigsty-acl.jpg](https://repo.pigsty.cc/img/pigsty-acl.jpg)](PGSQL-ACL)

如果您希望进一步加固系统的安全性，那么以下建议供您参考：

----------------

## 机密性

### 重要文件

**保护你的 pigsty.yml 配置文件或CMDB**
- `pigsty.yml` 配置文件通常包含了高度敏感的机密信息，您应当确保它的安全。
- 严格控制管理节点的访问权限，仅限 DBA 或者 Infra 管理员访问。
- 严格控制 pigsty.yml 配置文件仓库的访问权限（如果您使用 git 进行管理）


**保护你的 CA 私钥和其他证书，这些文件非常重要。**
- 相关文件默认会在管理节点Pigsty源码目录的 `files/pki` 内生成。
- 你应该定期将它们备份到一个安全的地方存储。

<br>

----------------

### 密码

**在生产环境部署时，必须更改这些密码，不要使用默认值！**
- [`grafana_admin_password`](param#grafana_admin_password)   : `pigsty`
- [`pg_admin_password`](param#pg_admin_password)             : `DBUser.DBA`
- [`pg_monitor_password`](param#pg_monitor_password)         : `DBUser.Monitor`
- [`pg_replication_password`](param#pg_replication_password) : `DBUser.Replicator`
- [`patroni_password`](param#patroni_password)               : `Patroni.API`
- [`haproxy_admin_password`](param#haproxy_admin_password)   : `pigsty`
- [`minio_secret_key`](param#minio_secret_key)               : `minioadmin`

**如果您使用MinIO，请修改MinIO的默认用户密码，与pgbackrest中的引用**
- 请修改 MinIO 普通用户的密码：[`minio_users`.`[pgbacrest]`.`secret_key`](PARAM#minio_users)
- 请修改 pgbackrest 中对 MinIO 使用的备份用户密码：[`pgbackrest_repo`.`minio`.`s3_key_secret`](PARAM#pgbackrest_repo)

**如果您使用远程备份仓库，请务必启用备份加密，并设置加解密密码**
- 设置 [`pgbackrest_repo`.`*`.`cipher_type`](PARAM#pgbackrest_repo) 为 `aes-256-cbc`
- 设置密码时可以使用 `${pg_cluster}` 作为密码的一部分，避免所有集群使用同一个密码

**为 PostgreSQL 使用安全可靠的密码加密算法**
- 使用 [`pg_pwd_enc`](param#pg_pwd_enc) 默认值 `scram-sha-256` 替代传统的 `md5`
- 这是默认行为，如果没有特殊理由（出于对历史遗留老旧客户端的支持），请不要将其修改回 `md5`

**使用 `passwordcheck` 扩展强制执行强密码**。
- 在 [`pg_libs`](param#pg_libs) 中添加 `$lib/passwordcheck` 来强制密码策略。

**使用加密算法加密远程备份**
- 在 [`pgbackrest_repo`](param#pgbackrest_repo) 的备份仓库定义中使用 `repo_cipher_type` 启用加密

**为业务用户配置密码自动过期实践**
- 你应当为每个[业务用户](PGSQL-USER#定义用户)设置一个密码自动过期时间，以满足合规要求。
- 配置自动过期后，请不要忘记在巡检时定期更新这些密码。

  ```yaml
  - { name: dbuser_meta , password: Pleas3-ChangeThisPwd ,expire_in: 7300 ,pgbouncer: true ,roles: [ dbrole_admin ]    ,comment: pigsty admin user }
  - { name: dbuser_view , password: Make.3ure-Compl1ance  ,expire_in: 7300 ,pgbouncer: true ,roles: [ dbrole_readonly ] ,comment: read-only viewer for meta database }
  - { name: postgres     ,superuser: true  ,expire_in: 7300                        ,comment: system superuser }
  - { name: replicator ,replication: true  ,expire_in: 7300 ,roles: [pg_monitor, dbrole_readonly]   ,comment: system replicator }
  - { name: dbuser_dba   ,superuser: true  ,expire_in: 7300 ,roles: [dbrole_admin]  ,pgbouncer: true ,pool_mode: session, pool_connlimit: 16 , comment: pgsql admin user }
  - { name: dbuser_monitor ,roles: [pg_monitor] ,expire_in: 7300 ,pgbouncer: true ,parameters: {log_min_duration_statement: 1000 } ,pool_mode: session ,pool_connlimit: 8 ,comment: pgsql monitor user }
  ```

**不要将更改密码的语句记录到 postgres 日志或其他日志中**

  ```bash
  SET log_statement TO 'none';
  ALTER USER "{{ user.name }}" PASSWORD '{{ user.password }}';
  SET log_statement TO DEFAULT;
  ```

<br>

----------------

### IP地址

**为 postgres/pgbouncer/patroni 绑定指定的 IP 地址，而不是所有地址。**
- 默认的 [`pg_listen`](param#pg_listen) 地址是 `0.0.0.0`，即所有 IPv4 地址。
- 考虑使用 `pg_listen: '${ip},${vip},${lo}'` 绑定到特定IP地址（列表）以增强安全性。

**不要将任何端口直接暴露到公网IP上，除了基础设施出口Nginx使用的端口（默认80/443）**
- 出于便利考虑，Prometheus/Grafana 等组件默认监听所有IP地址，可以直接从公网IP端口访问
- 您可以修改它们的配置文件，只监听内网IP地址，限制其只能通过 Nginx 门户通过域名访问，你也可以当使用安全组，防火墙规则来实现这些安全限制。
- 出于便利考虑，Redis服务器默认监听所有IP地址，您可以修改 [`redis_bind_address`](PARAM#redis_bind_address) 只监听内网IP地址。

**使用 [HBA](pgsql-hba) 限制 postgres 客户端访问**
- 有一个增强安全性的配置模板：[`security.yml`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/security.yml)

**限制 patroni 管理访问权限：仅 infra/admin 节点可调用控制API**
- 默认情况下，这是通过 [`restapi.allowlist`](https://github.com/Vonng/pigsty/blob/master/roles/pgsql/templates/oltp.yml#L109) 限制的。

<br>

----------------

### 网络流量

**使用 SSL 和域名，通过Nginx访问基础设施组件**
- Nginx SSL 由 [`nginx_sslmode`](param#nginx_sslmode) 控制，默认为 `enable`。
- Nginx 域名由 [`infra_portal.<component>.domain`](param#infra_portal) 指定。

**使用 SSL 保护 Patroni REST API**
- [`patroni_ssl_enabled`](param#patroni_ssl_enabled) 默认为禁用。
- 由于它会影响健康检查和 API 调用。
- 注意这是一个全局选项，在部署前你必须做出决定。

**使用 SSL 保护 Pgbouncer 客户端流量**
- [`pgbouncer_sslmode`](param#pgbouncer_sslmode) 默认为 `disable`
- 它会对 Pgbouncer 有显著的性能影响，所以这里是默认关闭的。




----------------

## 完整性

**为关键场景下的 PostgreSQL 数据库集群配置一致性优先模式（例如与钱相关的库）**
- [`pg_conf`](param#pg_conf) 数据库调优模板，使用 `crit.yml` 将以一些可用性为代价，换取最佳的数据一致性。

**使用crit节点调优模板，以获得更好的一致性。**
- [`node_tune`](param#node_tune) 主机调优模板使用 `crit` ，可以以减少脏页比率，降低数据一致性风险。

**启用数据校验和，以检测静默数据损坏。**
- [`pg_checksum`](param#pg_checksum) 默认为 `off`，但建议开启。
- 当启用 [`pg_conf`](param#pg_conf) = `crit.yml` 数据库模板时，校验和是强制开启的。

**记录建立/切断连接的日志**
- 该配置默认关闭，但在 `crit.yml` 配置模板中是默认启用的。
- 可以手工[配置集群](pgsql-admin#配置集群)，启用 `log_connections` 和 `log_disconnections` 功能参数。

**如果您希望彻底杜绝PG集群在故障转移时脑裂的可能性，请启用watchdog**
- 如果你的流量走默认推荐的 HAProxy 分发，那么即使你不启用 watchdog，你也不会遇到脑裂的问题。 
- 如果你的机器假死，Patroni 被 `kill -9` 杀死，那么 watchdog 可以用来兜底：超时自动关机。
- 最好不要在基础设施节点上启用 watchdog。 


----------------

## 可用性

**对于关键场景的PostgreSQL数据库集群，请使用足够的节点/实例数量**
- 你至少需要三个节点（能够容忍一个节点的故障）来实现生产级的高可用性。
- 如果你只有两个节点，你可以容忍特定备用节点的故障。
- 如果你只有一个节点，请使用外部的 S3/MinIO 进行冷备份和 WAL 归档存储。

**对于 PostgreSQL，在可用性和一致性之间进行权衡**
- [`pg_rpo`](param#pg_rpo) : **可用性与一致性之间的权衡**
- [`pg_rto`](param#pg_rto) : **故障概率与影响之间的权衡**

**不要直接通过固定的 IP 地址访问数据库；请使用 VIP、DNS、HAProxy 或它们的排列组合**
- 使用 HAProxy 进行服务[接入](PGSQL-SVC#接入服务)
- 在故障切换/主备切换的情况下，Haproxy 将处理客户端的流量切换。

**在重要的生产部署中使用多个基础设施节点（例如，1~3）**
- 小规模部署或要求宽松的场景，可以使用单一基础设施节点 / 管理节点。
- 大型生产部署建议设置至少两个基础设施节点互为备份。

**使用足够数量的 etcd 服务器实例，并使用奇数个实例（1,3,5,7）**
- 查看 [ETCD 管理](ETCD#管理) 了解详细信息。