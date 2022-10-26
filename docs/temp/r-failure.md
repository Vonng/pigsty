# Common Failures



## Hardware Faults

| ID |        Name        |                Symptom                | Process |
| :--: | :-----------------: | :---------------------------------: | :--: |
| H01  |   Primary node down   |        pg_up = 0 for 1-3 minutes        | No immediate intervention required. <br />Additional examples after the fact<br />Removal from Access Domain<br />Execute [Case 8: Cluster Role Adjustment](r-sop#Case-8-PGSQL-Role-Adjustment) |
| H02  |   Replica node down   |                  pg_up = 0 for 1-3 minutes                   | No immediate intervention required<br />Adding examples after the fact.<br />Removal from Access Domain<br />Execute  [Case 8: Cluster Role Adjustment](r-sop#Case-8-PGSQL-Role-Adjustment) |
| H03  | Primary node network partition | Loss of all monitoring data of the primary instance, network unreachable | Confirm Failover status<br />Force Fencing old primary if necessary |
| H04  | Replica Node Network Partitioning | Loss of all monitoring data from the instance, network unreachable | Usually no effect, waiting for recovery<br />Contact O&M and network engineers to handle |
| H05  |    TCP the retransmission rate is too high    | TCP Retrans stay high for a long time, a lot of Conn Reset, a lot of query requests fail |  Find O&M and network engineers to handle  |
| H06  | Node memory error | EDAC counter growth, system error log | After confirming that there are no errors in the replica memory<br />Execute [Case 10: cluster primary-replica switch](r-sop#Case-10-Cluster-Switchover) |
| H07  | Bad blocks on disk, data corruption | Query results, and logs show error messages such as can't read block |  Execute [Case 10: cluster primary-replica switch](r-sop#Case-10-Cluster-Switchover)<br />Manual data recovery using data recovery tools  |
| R01  |             High CPU usage              | CPU / load / pressure index high |  topCheck for large CPU footprint programs and clean them up<br />As in the case of an avalanche, execute a kill query stop.  |
| R02  |     OOM appears     | Process Failure appears, OOM message, high memory usage, start using SWAP | Confirm memory, confirm SWAP<br />topCheck for large memory hogs and clean them up<br />Re-pulling the killed process<br />Emergency SWAP partition addition |
| R03  | Disk Full | Disk Write Full<br />Database Crash<br />A large number of shell commands cannot be executed | Remove `/pg/dummy` to free up emergency space<br />Check and handle WAL buildup<br />Check aa and process a  large number of Log files<br />Confirm whether the business has cleanable data |
| R06  | Disk/network card IO too high | Disk/NIC BandWidth too large<br />Disk > 2GB/s<br />Network > 1 GB/s | Check applications that use the network/disk, such as backups, to add speed limits. |




## Software Errors

|  ID  |                      Name                      |                           Symptom                            |                           Process                            |
| :--: | :--------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
| SP1  |             Database process abort             |           `ps aux` can't find the postgres process           | Check Postgres, Patroni status<br />Confirm Failover results, or perform Failover manually |
| SP2  |        Connection pool process aborted         |             `systemctl status pgbouncer` Failure             | [restart service component](r-sop#Case-3-Cluster-Config-Change-and-Restart) or [reset service component](r-sop#Case-11-Reset-Component) |
| SP3  |        Primary Patroni process aborted         |              `systemctl status patroni` Failure              |  As above, enter maintenance mode, reboot or reset Patroni   |
| SP4  |         Primary Consul process aborted         |              `systemctl status consul` Failure               |   As above, enter maintenance mode, reboot or reset Consul   |
| S05  |             HAProxy process aborts             |              `systemctl status haproxy` Failure              |              As above, restart or reset Haproxy              |
| S06  |         Connection pool contamination          | An error message similar to Cannot execute XXX on read-only transactions appears | Restart the Pgbouncer connection pool<br />or configure `server_reset_query` |
| S07  | Connection pool cannot connect to the database |             pgbouncer can not connect to server              | Check whether the user, password, and HBA configuration are correct<br />Execute [Case-4: Cluster Service User Creation](r-sop.md#Case-4-Create-PGSQL-Biz-User) to refresh the user |
| S08  |     Connection pool reaches QPS bottleneck     |    PGbouncer QPS reaches 3 to 4W, CPU usage reaches 100%     | Use multiple Pgbouncers (not recommended)<br />Use Default service to bypass Pgbouncer<br />Notify business side of speed limit |
| S09  |          DCS Server is not available           | In auto-switchover mode, all primary will go to the unwritable state after TTL | **Set all clusters to [maintenance mode](r-sop.md#maintenance-mode) immediately** <br /> |
| S10  |            DCS Agavailableavailable            | If it is a replica, it has no effect, if it is a primary, it will be demoted to a replica and the cluster is not writable | **Set all clusters to [maintenance mode](r-sop.md#maintenance-mode) immediately** |
| S11  |                 XID Wraparound                 |       Enter protection mode when age remaining 1000w.        | This problem should be avoided in advance through monitoring <br /> locate the over-aged databases and tables, perform emergency cleaning<br /> quickly locate the cause of blocking the vacuum and solve<br /> restore in single user mode |
| S12  |                  WAL Stacking                  |                  WAL size continues to grow                  | Execute `CHECKPOINT`multiple times <br />confirm the wal archive status <br /> confirm whether there are unfinished ultra-longg transactions from the replica <br /> confirm whether there are replication slots to prevent wal recycling |



## Human Errors

|  ID  |                             Name                             |             Symptom             |                           Process                            |
| :--: | :----------------------------------------------------------: | :-----------------------------: | :----------------------------------------------------------: |
| M01  |             Mistakenly deleted database clusters             |  The database cluster is gone   | Use cold standby to recover the cluster<br />Prepare to run  |
| M02  |       Mistakenly elevating an instance to the primary        |           split-brain           | No need to handle it in automatic mode, otherwise, split-brain |
| M03  |                    Erased data by mistake                    |        The data is gone         | Stop vacuum, use ` PG_ Dirtyread ` extract<br />extract from delayed cluster <br />extract and restore from cold standby |
| M04  |                         Erasure Form                         |        The table is gone        | Fetch from delayed cluster<br />Fetch and restore from cold standby |
| M05  |               Integer Sequence Number Overflow               |     Sequence exceeds INTMAX     | Refer to integer primary key online upgrade manual to handle |
| M06  | Insert data conflicts due to duplicate primary key serial numbers |     violate constratint ...     |           Grow serial number value (e.g. +100000)            |
| M07  |                Slow query queuing / avalanche                | Large number of slow query logs | Use pg_terminate_backend to periodically clean up slow queries (e.g. every 1 second) |
| M08  |                 Deadlock queuing / avalanche                 |          Lock stacking          | Use pg_terminate_backend to periodically clean up queries (e.g. every 1 second) |
| M09  |                      HBA denied access                       |      no HBA entry for xxx       |  [Case 6: APPLY-PGSQL-HBA](r-sop.md#case-6-APPLY-PGSQL-HBA)  |
| M10  |                     User password error                      |  password auth failure for xxx  | [Case 4: Create OGSQL Biz User](r-sop.md#case-4-Create-pgsql-biz-user) |
| M11  |                Insufficient access privileges                |     permission denied for x     | Check if the user created the object with the correct admin<br />Refer to [Default Privilege](https://github.com/Vonng/pigsty/blob/master/pigsty.yml#L793) to manually fix the object privileges |

