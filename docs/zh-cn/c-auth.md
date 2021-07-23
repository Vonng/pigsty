# HBA

PostgreSQL提供了标准的访问控制机制：[认证](c-auth.md)（Authentication）与[权限](c-privilege.md)（Privileges），认证与权限都基于[角色](c-user.md)（Role）与[用户](c-user.md)（User）系统。Pigsty提供了开箱即用的访问控制模型，可覆盖绝大多数场景下的安全需求。

本文介绍Pigsty使用的认证体系与HBA机制。HBA是Host Based Authentication的缩写，可以将其视作IP黑白名单。

## HBA配置方式

在Pigsty中，所有实例的HBA都由配置文件生成而来，最终生成的HBA规则因实例的角色（`pg_role`）而不同。
Pigsty的HBA由下列变量控制：

* `pg_hba_rules`: 环境统一的HBA规则
* `pg_hba_rules_extra`: 特定于实例或集群的HBA规则
* `pgbouncer_hba_rules`: 链接池使用的HBA规则
* `pgbouncer_hba_rules_extra`: 特定于实例或集群的链接池HBA规则

每个变量都是由下列样式的规则组成的数组：

```yaml
- title: allow intranet admin password access
  role: common
  rules:
    - host    all     +dbrole_admin               10.0.0.0/8          md5
    - host    all     +dbrole_admin               172.16.0.0/12       md5
    - host    all     +dbrole_admin               192.168.0.0/16      md5
```


## 基于角色的HBA

`role = common`的HBA规则组会安装到所有的实例上，
而其他的取值，例如（`role : primary`）则只会安装至`pg_role = primary`的实例上。
因此用户可以通过角色体系定义灵活的HBA规则。

作为**特例**，`role: offline` 的HBA规则，除了会安装至`pg_role == 'offline'`的实例，
也会安装至`pg_offline_query == true`的实例上。

HBA的渲染优先级规则为：

* hard_coded_rules           全局硬编码规则
* pg_hba_rules_extra.common  集群通用规则
* pg_hba_rules_extra.pg_role 集群角色规则
* pg_hba_rules.pg_role       全局角色规则
* pg_hba_rules.offline       集群离线规则
* pg_hba_rules_extra.offline 全局离线规则
* pg_hba_rules.common        全局通用规则


## 默认HBA规则

在默认配置下，主库与从库会使用以下的HBA规则：

* 超级用户通过本地操作系统认证访问
* 其他用户可以从本地用密码访问
* 复制用户可以从局域网段通过密码访问
* 监控用户可以通过本地访问
* 所有人都可以在元节点上使用密码访问
* 管理员可以从局域网通过密码访问
* 所有人都可以从内网通过密码访问
* 读写用户（生产业务账号）可以通过本地（链接池）访问
  （部分访问控制转交链接池处理）
* 在从库上：只读用户（个人）可以从本地（链接池）访问。
  （意味主库上拒绝只读用户连接）
* `pg_role == 'offline'` 或带有`pg_offline_query == true`的实例上，会添加允许`dbrole_offline`分组用户访问的HBA规则。

<details>

```ini
#==============================================================#
# Default HBA
#==============================================================#
# allow local su with ident"
local   all             postgres                               ident
local   replication     postgres                               ident

# allow local user password access
local   all             all                                    md5

# allow local/intranet replication with password
local   replication     replicator                              md5
host    replication     replicator         127.0.0.1/32         md5
host    all             replicator         10.0.0.0/8           md5
host    all             replicator         172.16.0.0/12        md5
host    all             replicator         192.168.0.0/16       md5
host    replication     replicator         10.0.0.0/8           md5
host    replication     replicator         172.16.0.0/12        md5
host    replication     replicator         192.168.0.0/16       md5

# allow local role monitor with password
local   all             dbuser_monitor                          md5
host    all             dbuser_monitor      127.0.0.1/32        md5

#==============================================================#
# Extra HBA
#==============================================================#
# add extra hba rules here




#==============================================================#
# primary HBA
#==============================================================#


#==============================================================#
# special HBA for instance marked with 'pg_offline_query = true'
#==============================================================#



#==============================================================#
# Common HBA
#==============================================================#
#  allow meta node password access
host    all     all                         10.10.10.10/32      md5

#  allow intranet admin password access
host    all     +dbrole_admin               10.0.0.0/8          md5
host    all     +dbrole_admin               172.16.0.0/12       md5
host    all     +dbrole_admin               192.168.0.0/16      md5

#  allow intranet password access
host    all             all                 10.0.0.0/8          md5
host    all             all                 172.16.0.0/12       md5
host    all             all                 192.168.0.0/16      md5

#  allow local read/write (local production user via pgbouncer)
local   all     +dbrole_readonly                                md5
host    all     +dbrole_readonly           127.0.0.1/32         md5





#==============================================================#
# Ad Hoc HBA
#===========================================================
```

</details>


### 修改HBA规则

HBA规则会在集群/实例初始化时自动生成。

用户可以在数据库集群/实例创建并运行后通过剧本修改并应用新的HBA规则：

```bash
./pgsql.yml -t pg_hba    # 通过-l指定目标集群
```
当数据库集簇目录被销毁重建后，新副本会拥有和集群主库相同的HBA规则
（因为从库的数据集簇目录是主库的二进制副本，而HBA规则也在数据集簇目录中）
这通常不是用户期待的行为。您可以使用上面的命令针对特定实例进行HBA修复。




## Pgbouncer HBA

在Pigsty中，Pgbouncer亦使用HBA进行访问控制，用法与Postgres HBA基本一致

* `pgbouncer_hba_rules`: 链接池使用的HBA规则
* `pgbouncer_hba_rules_extra`: 特定于实例或集群的链接池HBA规则

默认的Pgbouncer HBA规则允许从本地和内网通过密码访问

```bash
pgbouncer_hba_rules:                          # pgbouncer host-based authentication rules
  - title: local password access
    role: common
    rules:
      - local  all          all                                     md5
      - host   all          all                     127.0.0.1/32    md5

  - title: intranet password access
    role: common
    rules:
      - host   all          all                     10.0.0.0/8      md5
      - host   all          all                     172.16.0.0/12   md5
      - host   all          all                     192.168.0.0/16  md5


```