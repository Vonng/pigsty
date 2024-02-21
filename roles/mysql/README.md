# MySQL (Alpha)

> **世界上[“最流行”](PGSQL)的开源关系型数据库！**

Pigsty 可以用于部署/监控 MySQL，但仅用于监控，评估，迁移，对比，测试之用。且在离线软件包中不会包含 MySQL 相关的软件包，需要您手工添加至本地软件源中。


## RPM

```bash
https://repo.mysql.com/yum/
https://repo.mysql.com/yum/mysql-8.0-community/el/7/x86_64/
https://repo.mysql.com/yum/mysql-8.0-community/el/8/x86_64/
https://repo.mysql.com/yum/mysql-8.0-community/el/9/x86_64/
```

## Install

How to install mysql on the fly

```yaml
    test:
      hosts: { 10.10.10.88: { nodename: test } }
      vars:
        node_cluster: test
        node_repo_module: node,mysql
        repo_modules: node,mysql
        repo_upstream:                    # where to download #
          - { name: baseos         ,description: 'EL 8+ BaseOS'      ,module: node  ,releases: [  8,9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/BaseOS/$basearch/os/'         ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/BaseOS/$basearch/os/'      ,europe: 'https://mirrors.xtom.de/rocky/$releasever/BaseOS/$basearch/os/'     }}
          - { name: appstream      ,description: 'EL 8+ AppStream'   ,module: node  ,releases: [  8,9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/AppStream/$basearch/os/'      ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/AppStream/$basearch/os/'   ,europe: 'https://mirrors.xtom.de/rocky/$releasever/AppStream/$basearch/os/'  }}
          - { name: extras         ,description: 'EL 8+ Extras'      ,module: node  ,releases: [  8,9] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/extras/$basearch/os/'         ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/extras/$basearch/os/'      ,europe: 'https://mirrors.xtom.de/rocky/$releasever/extras/$basearch/os/'     }}
          - { name: epel           ,description: 'EL 8+ EPEL'        ,module: node  ,releases: [  8,9] ,baseurl: { default: 'http://download.fedoraproject.org/pub/epel/$releasever/Everything/$basearch/' ,china: 'https://mirrors.tuna.tsinghua.edu.cn/epel/$releasever/Everything/$basearch/' ,europe: 'https://mirrors.xtom.de/epel/$releasever/Everything/$basearch/'     }}
          - { name: powertools     ,description: 'EL 8 PowerTools'   ,module: node  ,releases: [  8  ] ,baseurl: { default: 'https://dl.rockylinux.org/pub/rocky/$releasever/PowerTools/$basearch/os/'     ,china: 'https://mirrors.aliyun.com/rockylinux/$releasever/PowerTools/$basearch/os/'  ,europe: 'https://mirrors.xtom.de/rocky/$releasever/PowerTools/$basearch/os/' }}
          - { name: mysql          ,description: 'MySQL'             ,module: mysql ,releases: [7,8,9] ,baseurl: { default: 'https://repo.mysql.com/yum/mysql-8.0-community/el/$releasever/$basearch/'  }}
        node_packages:
          - mysql-community*
          - etcd,logcli,mcli,redis,postgresql16
```

## PMM

how to install pmm: https://www.percona.com/software/pmm/quickstart

```bash
curl -fsSL https://www.percona.com/get/pmm | /bin/bash    # server (require docker)
sudo yum install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
sudo yum install pmm2-client
sudo pmm-admin config --server-insecure-tls --server-url=https://admin:<password>@pmm.example.com
```


MySQL Config Example

```yaml
all:

  children:

    test:
      hosts: { 10.10.10.88: { mysql_seq: 88, mysql_role: primary } }
      vars:
        mysql_cluster: test
        mysql_databases:
          - { name: meta }
        mysql_users:
          - { name: dbuser_meta, host: '%', password: 'dbuesr_meta', priv: { "*.*": "SELECT, UPDATE, DELETE, INSERT" } }
          - { name: dbuser_dba, host: '%', password: 'DBUser.DBA' ,priv: { "*.*": "ALL PRIVILEGES" } }
          - { name: dbuser_monitor, host: '%', password: 'DBUser.Monitor', connlimit: 3 , priv: { "*.*": "SELECT, PROCESS, REPLICATION CLIENT" } }  
```