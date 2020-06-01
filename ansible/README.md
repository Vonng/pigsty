# Ansible Playbooks

## **Infrastructure Initialization**

* [init-repo.yml](init-repo.yml): provision playbook to setup a local yum repo
* [init-node.yml](init-node.yml): init infrastructure for all nodes, packages, dcs,...
* [init-meta.yml](init-meta.yml): init meta/master/control node

## **Database Initialization**

* [`**initdb.yml**`](initdb.yml): **init database cluster** according to inventory
* [initdb-precheck.yml](initdb-postgres.yml): init postgresql environment (install,setup,config)
* [initdb-postgres.yml](initdb-postgres.yml): install postgresql and setup basic environment
* [initdb-primary.yml](initdb-primary.yml): init postgres primary instance
* [initdb-standby.yml](initdb-primary.yml): init postgres standby instances
* [initdb-pgbouncer.yml](initdb-pgbouncer.yml): init pgbouncer
* [initdb-monitor.yml](initdb-monitor.yml): init monitor components (reset consul node meta)
* [initdb-patroni.yml](initdb-patroni.yml): init patroni HA supervisor (optional)


## **Infrastructure Administration**

* reload-prometheus.yml

## **Database Administration**

* admin-report.yml
* admin-backup.yml
* admin-repack.yml
* admin-vacuum.yml
* admin-deploy.yml
* admin-restart.yml
* admin-reload.yml
* admin-createdb.yml
* admin-createuser.yml
* admin-edit-hba.yml
* admin-edit-config.yml
* admin-dump-schema.yml
* admin-dump-table.yml
* admin-copy-data.yml
* admin-pg-exporter-reload.yml

## **Database HA**

* ha-switchover.yml
* ha-failover.yml
* ha-election.yml
* ha-rewind.yml
* ha-restore.yml
* ha-pitr.yml
* ha-drain.yml
* ha-proxy-add.yml
* ha-proxy-remove.yml
* ha-proxy-switch.yml
* ha-repl-report.yml
* ha-repl-sync.yml
* ha-repl-retarget.yml
* ha-pool-retarget.yml
* ha-pool-pause.yml
* ha-pool-resume.yml
