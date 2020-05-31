# Ansible Playbooks

## **Infrastructure Initialization**

* [init-repo.yml](init-repo.yml): provision playbook to setup a local yum repo
* [init-node.yml](init-node.yml): init infrastructure for all nodes, packages, dcs,...
* [init-meta.yml](init-meta.yml): init meta/master/control node

## **Database Initialization**

* [init-postgres.yml](init-postgres.yml): init postgresql environment (install,setup,config)
* [init-primary.yml](init-primary.yml): init postgresql primary instance
* [init-standby.yml](init-primary.yml): init postgresql standby instances
* [init-pgbouncer.yml](init-pgbouncer.yml): init pgbouncer (pooling middleware)
* [init-monitor.yml](init-monitor.yml): init monitor components
* [init-patroni.yml](init-patroni.yml): init patroni HA supervisor (optional)


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
