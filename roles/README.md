# Ansible roles for pigsty

Ansible roles:

* [repo](repo/)

  Create local yum repo
  
* [node](node/)

  Provision node (hostname, dns, ntp, nameserver, features, tuned, repo, packages, admin users, etc... )

* [consul](consul/)

  Install consul (server or agent) on nodes

* [etcd](etcd/)

  Install etcd server and write etcd client config 

* [cloud](cloud/)

  Install cloud native packages (not used yet) 

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

* [proxy](proxy/)
    
  Install and launch proxy for postgres