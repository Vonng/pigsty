# Pigsty Deployment

> It takes 3 steps to deploy Pigsty： [Prepare](d-prepare.md), [Configure](v-config.md), [Playbook](p-playbook)

----------------



## [Preparation](d-prepare.md)

> Before installing Pigsty, you need to prepare the required resources: physical/virtual machine nodes, administrative users, and download Pigsty software.

- [Node provisioning](d-prepare.md#node preparation)
- [Meta-node provisioning](d-prepare.md#管理节点置备)
- [ Manage user provisioning](d-prepare.md#管理用户置备)
- [Software provisioning](d-prepare.md#软件置备)


----------------



## [Configuration](v-config.md)

> After completing the preparation, you need to indicate to Pigsty what infrastructure and database services you need via [config](v-config.md#configuration process).

* [Configure Infra](v-infra.md)
* [Configure Nodes](v-nodes.md)
* [Configure PGSQL Cluster](v-pgsql.md) / [Customize PGSQL Cluster](v-pgsql-customize.md) /[Deploy PGSQL Cluster](d-pgsql.md)
* [Configure Redis Cluster](v-redis.md)  / [Deploy Redis Cluster](d-redis.md)
* [Deploy MatrixDB Cluster](d-matrixdb.md)

----------------



## [Playbook Execution](p-playbook.md)

> The next step can be to land the requirements by [executing the playbook](p-playbook.md).

* [Install Pigsty on Meta](p-infra.md#infra) / [Pigsty Uninstall](p-infra.md#infra-remove)
* [Add nodes](p-nodes.md#nodes) / [Remove nodes](p-nodes.md#nodes-remove)
* [Deploy PGSQL cluster](p-pgsql.md#pgsql) / [Offline PGSQL cluster](p-pgsql.md#pgsql-remove)
* [Create PGSQL business user](p-pgsql.md#pgsql-createuser) / [Create PGSQL business database](p-pgsql.md#pgsql-createdb)
* [Deploy Redis cluster](p-redis.md#redis) / [Offline Redis cluster](p-redis.md#redis-remove)





----------------

## Deployment

* [Standard Deployment](d-deploy.md): Prepare to brand new nodes to complete the standard Pigsty deployment process.
* [sandbox deployment](d-sandbox.md.md): Pull up a local VM sandbox env with a single click using a pre-built `vagrant` template.
* Multi-Cloud Deployment: Use `terraform` template to pull up the required VM resources at the cloud service provider and perform the deployment.
* [Monitor Only Deployment](d-monly): Use single-node Pigsty to monitor existing database clusters.



