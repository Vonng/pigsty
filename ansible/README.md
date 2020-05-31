# Ansible Playbooks

## TL;DR

first-time run:

```bash
sudo make dns
```

launch entire cluster
```bash
make            # pull up all nodes, init-repo
make init       # init infrastructure and meta node
make initdb     # init database cluster
```


* [init-repo.yml](init-repo.yml): provision playbook to setup a local yum repo
* [init-node.yml](init-node.yml): init infrastructure for all nodes, packages, dcs,...
* [init-meta.yml](init-meta.yml): init meta/master/control node




