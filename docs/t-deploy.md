# Pigsty Deployment

Deploying Pigsty is divided into three steps: [preparation](t-prepare.md), [modify configuration](c-config.md), [execute script](# execute script)

Pigsty requires some [preparation](t-prepare.md) before deployment: configure the node with the correct permission configuration, download and install the relevant software. Once the preparation is complete, users should [modify the configuration](v-config.md) according to their needs and [execute the script](#execute the script) to adjust the system to the state described in the configuration. Among other things, **configuration** is where the focus of deploying Pigsty lies.

## Deployment method

* [Standard Deployment](t-deploy.md): completes the standard Pigsty deployment process on a prepared machine node.
* [sandbox deployment](s-sandbox.md) : Automatically prepares environment-defined virtual machine resources via `vagrant`, which greatly simplifies the Pigsty deployment process.
* [monitor-only deployment](t-monly.md) : A special deployment mode that uses Pigsty to monitor existing database clusters.

Regardless of the deployment, the process is divided into three steps: [prepare resources](t-prepare.md), [modify configuration](c-config.md), [execute script](p-playbook.md). pigsty requires some [preparation](t-prepare.md) before deployment: configure the nodes with the correct privilege configuration. Download and install the relevant software. Once the preparation is complete, the user should [modify the configuration](c-config.md) and [execute the script](p-playbook.md) to adjust the system to the state described in the configuration according to their needs. The two steps, preparation and execution, are very simple, and **configuration** is where the key points in deploying Pigsty come in.

## [preparation](t-prepare.md)

- [node provisioning](t-prepare.md#node provisioning)
- [Manage node provisioning](t-prepare.md#manage node provisioning)
- [Manage user provisioning](t-prepare.md#manage user provisioning)
- [software provisioning](t-prepare.md#software provisioning)

## [Modify configuration](c-config.md)

- [config entry](c-config#config entry)
- [config file](c-config#config file)
- [infrastructure-config](c-config#infrastructure-config)
- [database cluster configuration](c-config#database cluster configuration)
- [identity parameters](c-config#identity parameters)
- [connection information](c-config#connection information)
- [custom-business-user](c-user.md)
- [customize business database](c-database.md)
- [Custom Patroni configuration template](t-patroni-template.md)
- [Deep customization database template](t-customize-template.md)


## Execution script

* [Infrastructure initialization](p-infra.md)
* [database initialization](p-pgsql.md) (cluster creation, new instances)
* [Database offline](p-pgsql-remove.md) (Remove instance, remove cluster)
* [create business user](p-pgsql-createuser.md)
* [create business database](p-pgsql-createdb.md)
