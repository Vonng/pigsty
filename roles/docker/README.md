# Docker (ansible role)

This role will provision docker on nodes

* install docker
* launch docker
* add admin user to docker group
* load docker images if exists


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Install docker and docker-compose	TAGS: [docker, docker_install, node-docker]
Get current admin user	TAGS: [docker, docker_admin, node-docker]
Add admin user to docker group	TAGS: [docker, docker_admin, node-docker]
Make sure /etc/docker exists	TAGS: [docker, docker_config, node-docker]
Overwrite /etc/docker/daemon.json	TAGS: [docker, docker_config, node-docker]
Launch docker service unit	TAGS: [docker, docker_launch, node-docker]
Check docker image cache exists	TAGS: [docker, docker_image, node-docker]
Load docker image cache if exists	TAGS: [docker, docker_image, node-docker]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
docker_enabled: false            # enable docker on all nodes? (you can enable them on meta nodes only)
docker_cgroups_driver: systemd   # docker cgroup fs driver
docker_registry_mirrors: []      # docker registry mirror
docker_image_cache: /www/pigsty/docker.tar.lz4  # docker images tarball to be loaded if eixsts
```