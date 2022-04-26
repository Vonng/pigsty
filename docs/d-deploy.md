# Pigsty Deployment

> It takes three steps to deploy Pigsty： [Prepare](d-prepare.md), [Configure](v-config.md), [Playbook](p-playbook).

----------------



## [Preparation](d-prepare.md)

> Before installing Pigsty, you need to prepare the required resources: physical/VM nodes, admin users, and download Pigsty software.

- [Node provisioning](d-prepare.md#Node-Provisioning)
- [Meta node provisioning](d-prepare.md#Meta-Node-Provisioning)
- [ Admin provisioning](d-prepare.md#Admin-Provisioning)
- [Software provisioning](d-prepare.md#Software-Provisioning)


----------------



## [Configuration](v-config.md)

> After preparation, you need to indicate to Pigsty what infra and database services you need via [configure](v-config.md#configure).

* [Configure Infra](v-infra.md)
* [Configure Nodes](v-nodes.md)
* [Configure PGSQL Cluster](v-pgsql.md) / [Customize PGSQL Cluster](v-pgsql-customize.md) /[Deploy PGSQL Cluster](d-pgsql.md)
* [Configure Redis Cluster](v-redis.md)  / [Deploy Redis Cluster](d-redis.md)
* [Deploy MatrixDB Cluster](d-matrixdb.md)

----------------



## [Playbook Execution](p-playbook.md)

> The next step can be to land the requirements by [executing the playbook](p-playbook.md).

* [Install Pigsty on Meta](p-infra.md#infra) / [Pigsty Uninstall](p-infra.md#infra-remove)
* [Add Nodes](p-nodes.md#nodes) / [Remove Nodes](p-nodes.md#nodes-remove)
* [Deploy PGSQL Cluster](p-pgsql.md#pgsql) / [Offline PGSQL Cluster](p-pgsql.md#pgsql-remove)
* [Create PGSQL Business User](p-pgsql.md#pgsql-createuser) / [Create PGSQL Business Database](p-pgsql.md#pgsql-createdb)
* [Deploy Redis Cluster](p-redis.md#redis) / [Offline Redis Cluster](p-redis.md#redis-remove)





----------------

## Deployment

* [Standard Deployment](d-deploy.md): Prepare brand new nodes to complete the standard Pigsty deployment process.
* [Sandbox Deployment](d-sandbox.md.md): Pull up a local VM sandbox environment with one click using a pre-built `vagrant` template.
* Multi-Cloud Deployment: Use `terraform` template to pull up the required VM resources at the cloud service vendor and perform the deployment.
* [Monly Deployment](d-monly): Use singleton Pigsty to monitor existing database clusters.
