# Pigsty

## Pigsty v1.0.0 Documentation

**Battery-Included Open-Source PostgreSQL Distribution**


!> EN docs is auto-translated and will be calibrated later. Check [zh-cn](/zh-cn/) docs for latest updates.

?> Pigsty (/ˈpɪɡˌstaɪ/) is the abbreviation of "PostgreSQL In Graphic STYle". [zh-cn](zh-cn) docs

![](_media/what.svg)


Pigsty is a monitoring system that is specially designed for large scale PostgreSQL clusters. Along with a production-grade HA PostgreSQL cluster provisioning solution. It brings the best observability for PostgreSQL and .

Pigsty bring users the ultimate observability and smooth experience with postgres. It is an open source software based on Apache License 2.0. Aiming to lower the threshold of enjoying PostgreSQL.

Pigsty has been evolved over time and has been tested in real production environments by some companies. The latest version of Pigsty is v0.8. It is available for production usage now.



## Highlights

* **Battery-Included** : deliver all you need to run production-grade databases with one-click.
* **Monitoring System** based on [prometheus](https://prometheus.io/) & [grafana](https://grafana.com/) &  [pg_exporter](https://github.com/Vonng/pg_exporter)
* **Provisioning Solution** based on [ansible](https://docs.ansible.com/ansible/latest/index.html) in kubernetes style. scale at ease.
* **HA Architecture** based on [patroni](https://patroni.readthedocs.io/) and [haproxy](https://www.haproxy.org/). Self-healing and auto-failover in seconds
* **Service Discovery** and leader election based on DCS ([consul](https://www.consul.io/) / etcd), maintenance made easy.
* **Offline Installation** without Internet access. Fast, secure, and reliable.
* **Flexible Design** makes pigsty fully configurable & customizable & extensible.
* **Reliable Performance** verified in real-world production env (200+nodes, 1PB Data)


## Who needs Pigsty ?

* DBA/Architect/Ops
* Developers
* Data Analyst
* Student/Beginner on PostgreSQL

## Where to run Pigsty ?

* Running on bare metal and virtual machine
  * Officially supported OS : Linux x86_64 CentOS 7.8.2003
  * ssh access & root privilege (or admin user with sudo access)

* Running local sandbox on your own MacBook (or PC) powered by vagrant & virtualbox
  * 1-node standard sandbox (minimal: `1Core|1GB`)
  * 4-node complete sandbox (minimal: `1Core|1GB` x 4)
  * It's recommended to use at least `2Core|4GB` for admin node, and `1Core|2GB` for pgsql node
  
## How to get Pigsty ?

![](_media/how.svg)

Prepare a node (Linux x86_64 CentOS 7.8.2003) with root/sudo access, then:

```bash
git clone https://github.com/Vonng/pigsty && cd pigsty
./configure
make install
```

If `git` not available, use `curl` instead. 
Download prepacked packages `pkg.tgz` to accelerate installation (optional).

```bash
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.0.0/pigsty.tgz -o ~/pigsty.tgz  
curl -SL https://github.com/Vonng/pigsty/releases/download/v1.0.0/pkg.tgz    -o /tmp/pkg.tgz
```


## Monitoring

![](_media/overview-monitor.jpg)

## Provisioning

![](_media/access.svg)


## Examples

Check out the [Public Demo](http://g.pigsty.cc) to see pigsty monitoring dashboards


## Donate

Please consider donating if you think Pigsty is helpful to you or that my work is valuable. I am happy if you can star this [repo](https://github.com/Vonng/pigsty). :heart:



