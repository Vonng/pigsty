# Deployment

There are 3 typical deployment type for Pigsty:

  * [Standard Deployment](t-deploy.md): Install pigsty on a fresh CentOS 7 node with download & configure & install
  * [Sandbox Deployment](s-sandbox.md) : Launch vm nodes on your laptop, then perform the standard deployment procedure.
  * [Monitor-Only Deployment](t-monly.md) : Deploy infra to monitor existing PostgreSQL instances.

No matter which deployment type is used, It always takes 3 steps:

  * [Prepare](t-prepare.md)
  * [Configure](c-config.md)
  * [Execution](#execute)

## [Prepare](t-prepare.md)

- [Node Provisioning](t-prepare.md#node-provisioning)
- [Meta Node Provisioning](t-prepare.md#meta-provisioning)
- [Admin User Provisioning](t-prepare.md#admin-provisioning)
- [Software Provisioning](t-prepare.md#software-provisioning)

## [Configure](c-config.md)

- [Config Entry](c-config.md#config-entry)
- [Config File](c-config.md#config-file)
- [Infrastructure Config](c-config.md#infrastructure-config)
- [Database Cluster Config](c-config.md#database-cluster-configuration)
- [Identity Parameters](c-config.md#identity-parameters)
- [Connection Information](c-config.md#connect-parameters)
- [Custom Business User](c-user.md)
- [Customize business Database](c-database.md)
- [Custom Patroni Template](t-patroni-template.md)
- [Customize Database Content](t-customize-template.md)


## Execution

- [Infrastructure initialization](p-meta.md)
- [database initialization](p-pgsql.md) (cluster creation, new instances)
- [Database offline](p-pgsql-remove.md) (Remove instance, remove cluster)
- [create business user](p-pgsql-createuser.md)
- [create business database](p-pgsql-createdb.md)

