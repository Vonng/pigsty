# Ansible roles for pigsty

Ansible roles:

* [environ](environ/)

  Setup meta node environment

* [repo](repo/)
  
  Create local yum repo
  
* [node](node/)

  Provision node (hostname, dns, ntp, nameserver, features, tuned, repo, packages, admin users, etc... )

* [consul](consul/)

  Install consul (server or agent) on nodes

* [etcd](etcd/)

  Install etcd server and write etcd client config  
  
* [ca](ca/)

  Create certificate infrastructure

* [nginx](nginx/)

  Create reverse proxy nginx on meta node

* [prometheus](prometheus/)

  Install and provision prometheus
  
* [grafana](grafana/)

  Install and provision grafana
  
* [postgres](postgres/)
    
  Install and provision postgres clusters

* [monitor](monitor/)
    
  Install and provision postgres monitoring system

* [service](service/)
    
  Install and launch proxy for postgres

* [register](register/)

  Register cluster/instance to infrastructure

* [remove](remove/)

  Remove pgsql cluster/instance


## Optional Roles

* [loki](loki/)

  Setup loki (the logging database) on meta node

* [promtail](promtail/)

  Setup promtail (the logging collector) on common node
