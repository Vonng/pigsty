# 创建业务数据库

## 剧本概览

[**创建业务数据库**](pgsql-createdb)：可以在现有集群中创建新的数据库或修改现有**数据库**：[`pgsql-createdb.yml`](https://github.com/Vonng/pigsty/blob/master/pgsql-createdb.yml)

![](../_media/playbook/pgsql-createdb.svg)

强烈建议通过剧本或包装脚本与工具在已有集群中创建新数据库，这样可以确保：

* 配置文件清单与实际情况保持一致
* Pgbouncer连接池与数据库保持一致
* Grafana中所注册的数据源与实际情况保持一致。



## 日常管理

数据库的创建请参考 [数据库](c-database.md#创建数据库) 一节。

```bash
# 在 pg-test 集群创建名为 test 的数据库
./pgsql-createdb.yml -l pg-test -e pg_database=test
```

另外，有一个简单的包装脚本可以使用：

```bash
bin/createdb <pg_cluster> <dbname>
```



## 剧本说明

```yaml
#!/usr/bin/env ansible-playbook
---
#==============================================================#
# File      :   pgsql-createdb.yml
# Ctime     :   2021-02-27
# Mtime     :   2021-07-06
# Desc      :   create database on existing cluster
# Deps      :   templates/pg-db.sql
# Path      :   pgsql-createdb.yml
# Copyright (C) 2018-2021 Ruohang Feng (rh@vonng.com)
#==============================================================#

#==============================================================#
# How to create new database on existing postgres cluster ?    #
#==============================================================#
#  1.  Define new database in inventory (cmdb or config)
#      `all.children.<pg_cluster>.vars.pg_databases[i]`
#  2.  Execute this playbook on target cluster with arg pg_database
#      `pgsql-createdb.yml -l <pg_cluster> -e pg_database=<database.name>
#
#  This playbook will:
#   1. create database sql definition on `/pg/tmp/pg-db-{{ database.name }}.sql`
#   2. execute database creation/update sql on cluster leader instance
#   3. update /etc/pgbouncer/database.txt and reload pgbouncer if necessary
#   4. register database to grafana instance
#=============================================================================#
- name: Create new postgres database
  become: yes
  hosts: all
  gather_facts: no
  vars:

    # TODO (IMPORTANT): OVERWRITE THIS WITH CLI-ARG: `-e pg_database=<database.name>`
    pg_database: meta           # database NAME that will be created on target cluster
    register_datasource: true   # register newly created database to grafana ?

  tasks:
    #------------------------------------------------------------------------------
    # Preflight Check: validate pg_database and database definition
    # ------------------------------------------------------------------------------
    - name: Preflight
      tags: preflight
      connection: local
      block:
        - name: Validate pg_database
          assert:
            that:
              - pg_database is defined
              - pg_database != ''
              - pg_database != 'postgres'
            fail_msg: variable 'pg_database' should be specified to create target database

        - name: Fetch database definition
          set_fact:
            pg_database_definition={{ pg_databases | json_query(pg_database_definition_query) }}
          vars:
            pg_database_definition_query: "[?name=='{{ pg_database }}'] | [0]"

        - name: Check database definition
          assert:
            that:
              - pg_database_definition is defined
              - pg_database_definition != None
              - pg_database_definition != ''
              - pg_database_definition != {}
            fail_msg: database definition for {{ pg_database }} should exists in pg_databases

        - debug:
            msg: "{{ pg_database_definition }}"

    #------------------------------------------------------------------------------
    # Create database on cluster leader (inventory pg_role == 'primary')
    #------------------------------------------------------------------------------
    # create database according to database definition
    - include_tasks: roles/postgres/tasks/createdb.yml
      tags: createdb
      vars: { database: "{{ pg_database_definition }}" }

    #------------------------------------------------------------------------------
    # Reload Pgbouncer if Necessary (among entire cluster)
    #------------------------------------------------------------------------------
    - name: Reload pgbouncer to add database
      when: pg_database_definition.pgbouncer is not defined or pg_database_definition.pgbouncer|bool
      tags: reload
      systemd: name=pgbouncer state=reloaded enabled=yes daemon_reload=yes

    #------------------------------------------------------------------------------
    # Create datasource on grafana
    #------------------------------------------------------------------------------
    - name: Render datasource definition on meta node
      tags: datasource
      delegate_to: meta
      when: register_datasource|bool
      copy:
        dest: "/etc/pigsty/datasources/{{ insdb }}.json"
        content: |
          {
            "type": "postgres",
            "access": "proxy",
            "name": "{{ insdb }}",
            "url": "{{ inventory_hostname }}:{{ pg_port }}",
            "user": "{{ pg_monitor_username }}",
            "password": "{{ pg_monitor_password }}",
            "database": "{{ datname }}",
            "typeLogoUrl": "",
            "basicAuth": false,
            "basicAuthUser": "",
            "basicAuthPassword": "",
            "withCredentials": false,
            "isDefault": false,
            "jsonData": {
              "connMaxLifetime": 3600,
              "maxIdleConns": 1,
              "maxOpenConns": 8,
              "postgresVersion": {{ pg_version }}00,
              "sslmode": "disable",
              "tlsAuth": false,
              "tlsAuthWithCACert": false
            }
          }
        mode: 0600
      vars:
        datname: "{{ pg_database }}"
        insdb: "{{ pg_cluster }}-{{ pg_seq }}.{{ pg_database }}"

    - name: Load grafana datasource on meta node
      tags: datasource
      delegate_to: meta
      when: register_datasource|bool
      shell: |
        curl -X DELETE "{{ grafana_endpoint }}/api/datasources/name/{{ insdb }}" -u "{{ grafana_admin_username }}:{{ grafana_admin_password }}"  -H 'Content-Type: application/json' || true
        curl -X POST   "{{ grafana_endpoint }}/api/datasources/" -u "{{ grafana_admin_username }}:{{ grafana_admin_password }}"  -H 'Content-Type: application/json' -d @/etc/pigsty/datasources/{{ insdb }}.json || true
      vars:
        datname: "{{ pg_database }}"
        insdb: "{{ pg_cluster }}-{{ pg_seq }}.{{ datname }}"


...

```

## 任务详情

默认任务如下：

```yaml
playbook: ./pgsql-createdb.yml

  play #1 (all): Create new postgres database	TAGS: []
    tasks:
      Validate pg_database	TAGS: [preflight]
      Fetch database definition	TAGS: [preflight]
      Check database definition	TAGS: [preflight]
      debug	TAGS: [preflight]
      include_tasks	TAGS: [createdb]
      Reload pgbouncer to add database	TAGS: [reload]
      Render datasource definition on meta node	TAGS: [datasource]
      Load grafana datasource on meta node	TAGS: [datasource]
```

![](../_media/playbook/pgsql-createdb.svg)





## 使用样例



```bash
./pgsql-createdb.yml -l pg-meta -e pg_database=meta
bin/createdb pg-meta meta            # alternative
```

<details>
<summary>执行结果</summary>

```yaml
PLAY [Create new postgres database] ***********************************************************************************************************************************************

TASK [Validate pg_database] *******************************************************************************************************************************************************
ok: [10.10.10.10] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [Fetch database definition] **************************************************************************************************************************************************
ok: [10.10.10.10]

TASK [Check database definition] **************************************************************************************************************************************************
ok: [10.10.10.10] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [debug] **********************************************************************************************************************************************************************
ok: [10.10.10.10] => {
    "msg": {
        "baseline": "cmdb.sql",
        "comment": "pigsty meta database",
        "connlimit": -1,
        "extensions": [
            {
                "name": "adminpack",
                "schema": "pg_catalog"
            },
            {
                "name": "postgis",
                "schema": "public"
            }
        ],
        "name": "meta",
        "schemas": [
            "pigsty"
        ]
    }
}

TASK [include_tasks] **************************************************************************************************************************************************************
included: /Users/vonng/pigsty/roles/postgres/tasks/createdb.yml for 10.10.10.10

TASK [debug] **********************************************************************************************************************************************************************
ok: [10.10.10.10] => {
    "msg": {
        "baseline": "cmdb.sql",
        "comment": "pigsty meta database",
        "connlimit": -1,
        "extensions": [
            {
                "name": "adminpack",
                "schema": "pg_catalog"
            },
            {
                "name": "postgis",
                "schema": "public"
            }
        ],
        "name": "meta",
        "schemas": [
            "pigsty"
        ]
    }
}

TASK [Render database meta creation sql] ******************************************************************************************************************************************
changed: [10.10.10.10]

TASK [Render database meta baseline sql] ******************************************************************************************************************************************
ok: [10.10.10.10]

TASK [Execute database meta creation command] *************************************************************************************************************************************
changed: [10.10.10.10]

TASK [Execute database meta creation sql] *****************************************************************************************************************************************
changed: [10.10.10.10]

TASK [Execute database meta baseline sql] *****************************************************************************************************************************************
changed: [10.10.10.10]

TASK [Add biz database to pgbouncer] **********************************************************************************************************************************************
changed: [10.10.10.10]

TASK [Reload pgbouncer to add database] *******************************************************************************************************************************************
changed: [10.10.10.10]

TASK [Render datasource definition on meta node] **********************************************************************************************************************************
changed: [10.10.10.10 -> meta]

TASK [Load grafana datasource on meta node] ***************************************************************************************************************************************
changed: [10.10.10.10 -> meta]

PLAY RECAP ************************************************************************************************************************************************************************
10.10.10.10                : ok=15   changed=8    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

</details>





