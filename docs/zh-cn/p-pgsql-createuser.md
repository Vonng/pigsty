# 创建业务用户

> 如何在用户集群中新建或修改业务用户？


## 剧本概览

[**创建业务用户**](pgsql-createuser)：可以在现有集群中创建新的用户或修改现有**用户**：[`pgsql-createuser.yml`](https://github.com/Vonng/pigsty/blob/master/pgsql-createuser.yml)

![](../_media/playbook/pgsql-createuser.svg)

## 日常管理

业务用户的创建请参考 [用户](c-user.md#创建用户) 一节

```bash
# 在 pg-test 集群创建名为 test 的用户
./pgsql-createuser.yml -l pg-test -e pg_user=test
```

可以使用包装脚本简化命令：

```bash
bin/createuser <pg_cluster> <username>
```

请注意，`pg_user` 指定的用户，**必须**已经存在于集群`pg_users`的定义中，否则会报错。这意味着用户必须先定义，再创建。

## 剧本说明


<details>
<summary>原始剧本</summary>

```yaml
#!/usr/bin/env ansible-playbook
---
#==============================================================#
# File      :   pgsql-createuser.yml
# Ctime     :   2021-02-27
# Mtime     :   2021-07-06
# Desc      :   create user/role on existing cluster
# Path      :   pgsql-createuser.yml
# Deps      :   templates/pg-user.sql
# Copyright (C) 2018-2022 Ruohang Feng (rh@vonng.com)
#==============================================================#


#==============================================================#
# How to create new user/role on existing postgres cluster ?   #
#==============================================================#
#  1.  Define new user/role in inventory (cmdb or config)
#      `all.children.<pg_cluster>.vars.pg_users[i]`
#  2.  Execute this playbook on target cluster with arg pg_user
#      `pgsql-createuser.yml -l <pg_cluster> -e pg_user=<user.name>
#
#  This playbook will:
#   1. create user sql definition on `/pg/tmp/pg-user-{{ user.name }}.sql`
#   2. execute database creation/update sql on cluster leader instance
#   3. update /etc/pgbouncer/userlist.txt and reload pgbouncer if necessary
#=============================================================================#
- name: Create new postgres user
  become: yes
  hosts: all
  gather_facts: no
  vars:

    # TODO (IMPORTANT): SET OR PASS CLI-ARG: `-e pg_user=<user.name>`
    # pg_user: dbuser_meta

  tasks:
    #------------------------------------------------------------------------------
    # pre-flight check: validate pg_user and user definition
    # ------------------------------------------------------------------------------
    - name: Preflight
      tags: preflight
      connection: local
      block:
        - name: Validate pg_user
          assert:
            that:
              - pg_user is defined
              - pg_user != ''
              - pg_user != 'postgres'
            fail_msg: variable 'pg_user' should be specified to create target user

        - name: Fetch user definition
          set_fact:
            pg_user_definition={{ pg_users | json_query(pg_user_definition_query) }}
          vars:
            pg_user_definition_query: "[?name=='{{ pg_user }}'] | [0]"

        - name: Check user definition
          assert:
            that:
              - pg_user_definition is defined
              - pg_user_definition != None
              - pg_user_definition != ''
              - pg_user_definition != {}
            fail_msg: user definition for {{ pg_user }} should exists in pg_users

        - debug:
            msg: "{{ pg_user_definition }}"

    #------------------------------------------------------------------------------
    # Create user on cluster leader (inventory pg_role == 'primary')
    #------------------------------------------------------------------------------
    # create user according to user definition
    - include_tasks: roles/postgres/tasks/createuser.yml
      vars: { user: "{{ pg_user_definition }}" }

    #------------------------------------------------------------------------------
    # Reload Pgbouncer if Necessary (among entire cluster)
    #------------------------------------------------------------------------------
    - name: Reload pgbouncer to add user
      when: pg_user_definition.pgbouncer is defined and pg_user_definition.pgbouncer|bool
      tags: pgbouncer_reload
      systemd: name=pgbouncer state=reloaded enabled=yes daemon_reload=yes


...

```




## 任务详情

默认任务如下：

```yaml
playbook: ./pgsql-createuser.yml

  play #1 (all): Create new postgres user	TAGS: []
    tasks:
      Validate pg_user	TAGS: [preflight]
      Fetch user definition	TAGS: [preflight]
      Check user definition	TAGS: [preflight]
      debug	TAGS: [preflight]
      include_tasks	TAGS: []
      Reload pgbouncer to add user	TAGS: [pgbouncer_reload]
```

</details>





## 使用样例



```bash
./pgsql-createuser.yml -l pg-meta -e pg_user=dbuser_meta
bin/createuser pg-meta dbuser_meta         # alternative
```

<details>
<summary>执行结果</summary>

```yaml
$ ./pgsql-createuser.yml -l pg-test -e pg_user=test
[WARNING]: Invalid characters were found in group names but not replaced, use -vvvv to see details

PLAY [Create user in cluster] *****************************************************************************************************************************************************

TASK [Check parameter pg_user] ****************************************************************************************************************************************************
ok: [10.10.10.11] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [10.10.10.12] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [10.10.10.13] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [Fetch user definition] ******************************************************************************************************************************************************
ok: [10.10.10.11]
ok: [10.10.10.12]
ok: [10.10.10.13]

TASK [debug] **********************************************************************************************************************************************************************
ok: [10.10.10.11] => {
    "msg": {
        "comment": "default test user for production usage",
        "name": "test",
        "password": "test",
        "pgbouncer": true,
        "roles": [
            "dbrole_readwrite"
        ]
    }
}
ok: [10.10.10.12] => {
    "msg": {
        "comment": "default test user for production usage",
        "name": "test",
        "password": "test",
        "pgbouncer": true,
        "roles": [
            "dbrole_readwrite"
        ]
    }
}
ok: [10.10.10.13] => {
    "msg": {
        "comment": "default test user for production usage",
        "name": "test",
        "password": "test",
        "pgbouncer": true,
        "roles": [
            "dbrole_readwrite"
        ]
    }
}

TASK [Check user definition] ******************************************************************************************************************************************************
ok: [10.10.10.11] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [10.10.10.12] => {
    "changed": false,
    "msg": "All assertions passed"
}
ok: [10.10.10.13] => {
    "changed": false,
    "msg": "All assertions passed"
}

TASK [include_tasks] **************************************************************************************************************************************************************
included: /Volumes/Data/pigsty/roles/postgres/tasks/createuser.yml for 10.10.10.11, 10.10.10.12, 10.10.10.13

TASK [Render user test creation sql] **********************************************************************************************************************************************
skipping: [10.10.10.12]
skipping: [10.10.10.13]
changed: [10.10.10.11]

TASK [Execute user test creation sql on primary] **********************************************************************************************************************************
skipping: [10.10.10.12]
skipping: [10.10.10.13]
changed: [10.10.10.11]

TASK [Add user to pgbouncer] ******************************************************************************************************************************************************
changed: [10.10.10.11]
changed: [10.10.10.13]
changed: [10.10.10.12]

TASK [Reload pgbouncer to add user] ***********************************************************************************************************************************************
changed: [10.10.10.11]
changed: [10.10.10.12]
changed: [10.10.10.13]

PLAY RECAP ************************************************************************************************************************************************************************
10.10.10.11                : ok=9    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
10.10.10.12                : ok=7    changed=2    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0
10.10.10.13                : ok=7    changed=2    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0

```

</details>





