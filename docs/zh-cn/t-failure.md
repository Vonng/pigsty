# 数据库常见故障诊断与处理

### 硬件故障

| 编号 |        名称         |                症状                 | 处理 |
| :--: | :-----------------: | :---------------------------------: | :--: |
| H01  |   Primary节点宕机   |        pg_up = 0 持续1-3分钟        | 无需立即介入。<br />事后补充实例<br />从接入域名摘除<br />执行 [Case 8：集群角色调整](t-operation#case-8：集群角色调整) |
| H02  |   Replica节点宕机   |        pg_up = 0 持续1-3分钟        | 无需立即介入。<br />事后补充实例，<br />从接入域名摘除<br />执行 [Case 8：集群角色调整](t-operation#case-8：集群角色调整) |
| H03  | Primary节点网络分区 | 失去 主实例所有监控数据，网路不可达 | 确认Failover情况<br />必要时强制Fencing旧主库 |
| H04  | Replica节点网络分区 | 失去 从实例所有监控数据，网路不可达 | 通常无影响，等待恢复<br />联系运维与网络工程师处理 |
| H05  |    TCP重传率过高    | TCP Retrans长时间居高不下，大量Conn Reset，大量查询请求失败 |  找运维与网络工程师处理  |
| H06  |    节点内存错误     | EDAC计数器增长，系统错误日志 | 确认从库内存无错后<br />执行[Case 10：集群主从切换](t-operation#case-10：集群主从切换) |
| H07  | 磁盘坏块，数据腐坏  | 查询结果与日志出现 can't read block  等错误信息 |  执行[Case 10：集群主从切换](t-operation#case-10：集群主从切换)<br />使用数据恢复工具，人工恢复数据  |
| R01  |   CPU使用率高   | CPU / Load / Pressure指标高 |  top确认大CPU占比程序并清理<br />如为雪崩，执行杀查询止损。  |
| R02  |     出现OOM     | 出现进程Failure，OOM消息，内存使用高，开始使用SWAP | 确认内存，确认SWAP<br />top确认大内存占用程序并清理<br />重新拉起被杀进程<br />紧急添加SWAP分区 |
| R03  |     磁盘满      | 磁盘写满<br />数据库Crash<br />大量shell命令无法执行 | 移除 `/pg/dummy` 释放应急空间<br />检查并处理WAL堆积<br />检查并处理大量Log文件<br />确认业务是否有可清理数据 |
| R06  | 磁盘/网卡IO过高 | 磁盘/网卡 BandWidth过大<br />磁盘 > 2GB/s<br />网络 > 1 GB/s |       检查使用网络/磁盘的应用程序，如备份，添加限速。        |




### 软件故障

| 编号 |          名称           |                             症状                             |                             处理                             |
| :--: | :---------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
| SP1  |     数据库进程中止      |             `ps aux | grep postgres` 找不到进程              |  检查Patroni状态<br />确认Failover结果，或手工执行Failover   |
| SP2  |     连接池进程中止      |             `systemctl status pgbouncer` Failure             | [重启服务组件](t-operation#服务组件管理重启) 或 [重置服务组件](t-operation#case-11：重置组件) |
| SP3  | Primary Patroni进程中止 |              `systemctl status patroni` Failure              |            同上，进入维护模式，重启或重置 Patroni            |
| SP4  | Primary Consul进程中止  |              `systemctl status consul` Failure               |            同上，进入维护模式，重启或重置 Consul             |
| S05  |     HAProxy进程中止     |              `systemctl status haproxy` Failure              |                   同上，重启或重置 Haproxy                   |
| S06  |       连接池污染        | 出现类似于 Cannot execute xxx on readonly transactions 的报错 |     重启Pgbouncer连接池<br />或配置 `server_reset_query`     |
| S07  | 连接池无法连接至数据库  |             pgbouncer can not connect to server              | 检查用户、密码、HBA配置是否正确<br />执行 [Case 4：集群业务用户创建](case-4：集群业务用户创建) 刷新用户 |
| S08  |    连接池达到QPS瓶颈    |         PGbouncer QPS 达到 3～4W，CPU使用率达到100%          | 使用多个Pgbouncer（不推荐）<br />使用Default服务绕开Pgbouncer<br />通知业务方限速 |
| S09  |    DCS Server不可用     |       自动切换模式下，所有主库将在TTL后进入不可写状态        | **立即将所有集群设置为[维护模式](t-operation#维护模式)**<br /> |
| S10  |     DCS Agent不可用     |     若为从库无影响，若为主库，会降级为从库，集群不可写入     |    **立即将该集群设置为[维护模式](t-operation#维护模式)**    |
| S11  |     XID Wraparound      |               年龄剩余1000w时，进入保护模式。                | 应通过监控提前避免此问题<br />定位年龄过大的数据库与表，执行紧急清理<br />迅速定位阻塞Vacuum的原因并解决<br />进入单用户模式下恢复 |
| S12  |         WAL堆积         |                       WAL大小持续增长                        | 多次执行`CHECKPOINT`<br />确认WAL归档状态<br />确认从库上是否有未结束超长事务<br />确认是否有复制槽阻止WAL回收 |



### 人为问题

| 编号 |              名称              |             症状              |                             处理                             |
| :--: | :----------------------------: | :---------------------------: | :----------------------------------------------------------: |
| M01  |         误删数据库集群         |        数据库集群没了         |                使用冷备恢复集群<br />准备跑路                |
| M02  |      误将某实例提升为主库      |             脑裂              |                 自动模式下无需处理，否则脑裂                 |
| M03  |            误删数据            |           数据没了            | 停止VACUUM，使用 `pg_dirtyread`提取。<br />从延迟备库中提取<br />从冷备份中提取并恢复 |
| M04  |             误删表             |            表没了             |          从延迟备库中提取<br />从冷备份中提取并恢复          |
| M05  |         整型序列号溢出         |      Sequence超出INTMAX       |                 参考整型主键在线升级手册处理                 |
| M06  | 插入数据因主键序列号重复而冲突 |    violate constratint ...    |                  增长序列号值（如+100000）                   |
| M07  |        慢查询堆积/雪崩         |        大量慢查询日志         |    使用 pg_terminate_backend 周期性清理慢查询（如每1秒）     |
| M08  |         死锁堆积/雪崩          |            锁堆积             |     使用 pg_terminate_backend 周期性清理查询（如每1秒）      |
| M09  |          HBA拒绝访问           |     no hba entry for xxx      | [Case 6：集群HBA规则调整](t-operation#case-6：集群HBA规则调整) |
| M10  |          用户密码错误          | password auth failure for xxx |     [Case 4：集群业务用户创建](case-4：集群业务用户创建)     |
| M11  |          访问权限不足          |    permission denied for x    | 检查用户是否使用正确的管理员创建对象<br />参考 [Default Privilege](https://github.com/Vonng/pigsty/blob/master/pigsty.yml#L793) 手工修正对象权限 |



# 
