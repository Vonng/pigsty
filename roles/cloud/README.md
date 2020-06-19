# DCS (ansible role)

This role will provision cloud native infrastructure (docker & kubernetes)

* install docker
  * load docker images if exists

* init kubernetes
  * install kubernetes (from mirror)
  * kubeadm init master
  * install network add-on calico
  * install dashboard add-on
  * copy kubernetes credential
  * join non-master nodes to cluster


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
tasks:
  cloud : Install docker and kubernetes		TAGS: [docker_setup, infra]
  cloud : Add vagrant to docker group		TAGS: [docker_setup, infra]
  cloud : Make sure /etc/docker exists		TAGS: [docker_setup, infra]
  cloud : Overwrite /etc/docker/daemon.json	TAGS: [docker_setup, infra]
  cloud : Launch docker service unit		TAGS: [docker_setup, infra]
  cloud : Check pigsty repo cache exists	TAGS: [docker_setup, infra]
  cloud : Load docker image cache if exists	TAGS: [docker_setup, infra]
  cloud : Config kubelet default options	TAGS: [infra, k8s_master]
  cloud : Kubeadm config images pull test	TAGS: [infra, k8s_master]
  cloud : Kubeadm init kubeternetes master	TAGS: [infra, k8s_master]
  cloud : Enable kubelet service unit		TAGS: [infra, k8s_master]
  cloud : Setup kubeconfig for root user	TAGS: [infra, k8s_master]
  cloud : Setup kubeconfig for vagrant user	TAGS: [infra, k8s_master]
  cloud : Copy calio and k8s dashboard yml	TAGS: [infra, k8s_master]
  cloud : Install calico pod network addon	TAGS: [infra, k8s_master]
  cloud : Install kubernetes dashboard		TAGS: [infra, k8s_master]
  cloud : Create kubernetes-dashboard user	TAGS: [infra, k8s_master]
  cloud : Generate kubernetes join scripts	TAGS: [infra, k8s_master]
  cloud : Copy join command to local file	TAGS: [infra, k8s_master]
  cloud : Cat /etc/kubernetes/admin.conf	TAGS: [infra, k8s_master]
  cloud : Copy admin.conf to local file		TAGS: [infra, k8s_master]
  cloud : Get kubernetes admin token		TAGS: [infra, k8s_master]
  cloud : Copy admin token to local file	TAGS: [infra, k8s_master]
  cloud : Execute join.sh command on nodes	TAGS: [infra, k8s_nodes]
  cloud : Enable node kubelet service		TAGS: [infra, k8s_nodes]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
# docker & k8s
docker_cgroups_driver: systemd                                    # docker default cgroup fs driver
docker_registry_mirrors: []                                       # docker registry mirror
docker_image_cache: /www/pigsty/docker-images.tar.lz4             # docker images lz4 tar to be loaded
k8s_registry_mirrors: registry.aliyuncs.com/google_containers     # kubernetes versionaliyun k8s miiror repository

k8s_servers: []                                                   # kubernetes servers (REQUIRED)
k8s_version: 1.18.3                                               # kubernetes version
k8s_pod_cidr: "10.11.0.0/16"                                      # kubernetes pod network cidr
k8s_service_cidr: "10.12.0.0/16"                                  # kubernetes service network cidr
k8s_dashboard_admin_user: dashboard-admin-sa                      # kubernetes dashboard admin user name

k8s_role: node                                                    # default kubernetes role (override for masters)
```