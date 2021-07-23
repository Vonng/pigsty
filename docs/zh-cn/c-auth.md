
HBA是Host Based Authentication的缩写，可以将其视作IP黑白名单。

## HBA配置方式

在Pigsty中，所有实例的HBA都由配置文件生成而来，最终生成的HBA规则取决于实例的角色（`pg_role`）
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

`role = common`的HBA规则组会安装到所有的实例上，而其他的取值，例如（`role : primary`）则只会安装至`pg_role = primary`的实例上。因此用户可以通过角色体系定义灵活的HBA规则。

作为一个**特例**，`role: offline` 的HBA规则，除了会安装至`pg_role == 'offline'`的实例，也会安装至`pg_offline_query == true`的实例上。



## 默认配置

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

