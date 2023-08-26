# 安全考量

> Pigsty 的默认配置已经足以覆盖绝大多数场景对于安全的需求。

如果您希望进一步加固系统的安全性，那么以下建议供您参考：


----------------

## 机密性


**保护你的 pigsty.yml 配置文件或CMDB**
- `pigsty.yml` 配置文件通常包含了高度敏感的机密信息，您应当确保它的安全。
- 严格控制管理节点的访问权限，仅限 DBA 或者 Infra 管理员访问。
- 严格控制 pigsty.yml 配置文件仓库的访问权限（如果您使用 git 进行管理）


**保护你的 CA 私钥和其他证书，这些文件非常重要。**
- 相关文件默认会在管理节点Pigsty源码目录的 `files/pki` 内生成。
- 你应该定期将它们备份到一个安全的地方存储。

<br>

### 密码

**在生产环境部署时，必须更改这些密码，不要使用默认值！**
- [`grafana_admin_password`](param#grafana_admin_password)   : `pigsty`
- [`pg_admin_password`](param#pg_admin_password)             : `DBUser.DBA`
- [`pg_monitor_password`](param#pg_monitor_password)         : `DBUser.Monitor`
- [`pg_replication_password`](param#pg_replication_password) : `DBUser.Replicator`
- [`patroni_password`](param#patroni_password)               : `Patroni.API`
- [`haproxy_admin_password`](param#haproxy_admin_password)   : `pigsty`

**为 PostgreSQL 使用安全可靠的密码加密算法**
- 使用 [`pg_pwd_enc`](param#pg_pwd_enc) 默认值 `scram-sha-256` 替代传统的 `md5`
- 这是默认行为，如果没有特殊理由（出于对历史遗留老旧客户端的支持），请不要将其修改回 `md5`

**使用 `passwordcheck` 扩展强制执行强密码**。
- 在 [`pg_libs`](param#pg_libs) 中添加 `$lib/passwordcheck` 来强制密码策略。

**使用加密算法加密远程备份**
- 在 [`pgbackrest_repo`](param#pgbackrest_repo) 的备份仓库定义中使用 `repo_cipher_type` 启用加密

**为业务用户配置密码自动过期实践**
- 你应当为每个业务用户设置一个密码自动过期时间，以满足合规要求。
- 配置自动过期后，请不要忘记在巡检时定期更新这些密码。

**不要将更改密码的语句记录到 postgres 日志或其他日志中**

  ```bash
  SET log_statement TO 'none';
  ALTER USER "{{ user.name }}" PASSWORD '{{ user.password }}';
  SET log_statement TO DEFAULT;
  ```

<br>

### IP地址

**为 postgres/pgbouncer/patroni 绑定指定的 IP 地址，而不是所有地址。**
- 默认的 [`pg_listen`](param#pg_listen) 地址是 `0.0.0.0`，即所有 IPv4 地址。
- 考虑使用 `pg_listen: '${ip},${vip},${lo}'` 绑定到特定IP地址（列表）以增强安全性。

**不要将任何端口直接暴露到公网IP上，除了基础设施出口Nginx使用的端口（默认80/443）**
- 你应当使用安全组或防火墙规则来实现它。

**使用 [HBA](pgsql/hba) 限制 postgres 客户端访问**
- 有一个增强安全性的配置模板：[`security.yml`](https://github.com/Vonng/pigsty/blob/master/files/pigsty/security.yml)

**限制 patroni 管理访问权限：仅 infra/admin 节点可调用控制API**
- 默认情况下，这是通过 [`restapi.allowlist`](https://github.com/Vonng/pigsty/blob/master/roles/pgsql/templates/oltp.yml#L109) 限制的。

<br>

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
- 可以手工[配置](pgsql-admin) `log_connections` and `log_disconnections` 参数启用此功能

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

**不要直接通过固定的 IP 地址访问数据库；请使用 VIP、DNS、HAProxy 或它们的排列组合。**
- 在故障切换/主备切换的情况下，Haproxy 将处理客户端的流量切换。

**在重要的生产部署中使用多个基础设施节点（例如，1~3）**
- 小规模部署或要求宽松的场景，可以使用单一基础设施节点 / 管理节点。
- 大型生产部署建议设置至少两个基础设施节点互为备份。

**使用足够数量的 etcd 服务器实例，并使用奇数个实例（1,3,5,7）**
- 查看 [ETCD 管理](etcd-admin) 了解详细信息。