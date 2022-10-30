# Pigsty

**Battery-Included PostgreSQL, open-source RDS of your own.**

![icon](https://user-images.githubusercontent.com/8587410/198861991-cd169e71-9d62-42ca-a3e0-db945d5751d9.svg)

> Latest Beta: [v1.6.0-b3](https://github.com/Vonng/pigsty/releases/tag/v1.6.0-b3) | Stable Version: [v1.5.1](https://github.com/Vonng/pigsty/releases/tag/v1.5.1)  |  [Demo](http://demo.pigsty.cc)
>
> Documentation: [Docs](https://pigsty.cc/en/) | [中文文档](https://pigsty.cc/zh/) | [Github Pages](https://vonng.github.io/pigsty/#/) | [Wiki](https://github.com/Vonng/pigsty/wiki)


![pigsty](https://user-images.githubusercontent.com/8587410/198840611-744709cb-cf25-4dff-a91d-c593347076a8.jpg)



--------

## What is Pigsty?


* [**Open Source RDS**](#): Open-Source alternative to public cloud RDS.
  <details><summary>Full-Featured Open-Source Alternative to RDS PostgreSQL</summary>

  ![RDS](https://user-images.githubusercontent.com/8587410/198838843-3b9c4c42-849b-48d3-9a13-25da10c33a86.gif)

  > If you can have a better RDS service with the price of EC2, Why use RDS at all?
  </details>
* [**Postgres Distribution**](#): PostgreSQL, PostGIS, TimescaleDB, Citus, Redis/GP, United in One!
  <details><summary>PostgreSQL Kernel, Extensions, Peripherals, and Companion</summary>

  ![DISTRO](https://user-images.githubusercontent.com/8587410/198838835-f9df4737-f109-4e5b-b5a0-f54aa1b33c5a.gif)

  > PostGIS, TimescaleDB, Citus, and hundreds of extensions!
  </details>

* [**Infra Best Practice**](#): Grafana, Prometheus, Loki, AlertManager, Docker, Battery-Included!
  <details><summary>Open Source Infrastructure Best Practice, Ship runtime with databases!</summary>

  ![ARCH](https://user-images.githubusercontent.com/8587410/198838831-d0f263cb-da99-46db-a33e-01e7a9c6e061.gif)

  > If you can have a better RDS service with the price of EC2, Why use RDS at all?
  </details>

* [**Developer Toolbox**](#): Manage production-ready HA database clusters in one command!
  <details><summary>GUI & CLI, Handling 70% of database administration work in minutes!</summary>

  ![INTERFACE](https://user-images.githubusercontent.com/8587410/198838840-898dbe75-8af7-4b87-9d18-02abc33f36eb.gif)

  > Define clusters in a declarative manner and materialize them with idempotent playbooks
  </details>

Check [**Architecture**](https://github.com/Vonng/pigsty/wiki/Architecture) & [**Demo**](http://demo.pigsty.cc) for details.




--------

## Why Pigsty?


* [**High-Availability**](#): Auto-Pilot Postgres with idempotent instances & services, self-healing from failures!
  <details><summary>High-Availability PostgreSQL Powered by Patroni & HAProxy</summary>

  ![HA](https://user-images.githubusercontent.com/8587410/198838836-433331a4-0df1-4588-944c-625c34430f2f.svg)

  > Self-healing on hardware failures: Failover impact on primary < 30s, Switchover impact < 1s
  </details>

* [**Ultimate Observability**](#): Unparalleled monitoring system based on modern open-source best-practice!!
  <details><summary>Observability powered by Grafana, Prometheus & Loki</summary>

  ![DASHBOARD](https://user-images.githubusercontent.com/8587410/198838834-1bd30b7e-47c9-4e35-90cb-5a75a2e6f6c6.jpg)

  > 3K+ metrics on 30+ dashboards, Check [http://demo.pigsty.cc](http://demo.pigsty.cc) for a live demo!

  </details>

* [**Database as Code**](#): Declarative config with idempotent playbooks. WYSIWYG and GitOps made easy!
  <details><summary>Define & Create a HA PostgreSQL Cluster in 10 lines of Code</summary>

  ![IAC](https://user-images.githubusercontent.com/8587410/198838838-91c3d193-f600-422c-b504-b9bbec076802.gif)

  > Create a 3-node HA PostgreSQL with 10 lines of config and one command!

  </details>

* [**IaaS Provisioning**](#): Bare metal or VM, Cloud or On-Perm, One-Click provisioning with Vagrant/Terraform

  <details><summary>Pigsty 4-nodes sandbox on Local Vagrant VM or AWS EC2</summary>

  ![SANDBOX](https://user-images.githubusercontent.com/8587410/198838845-09aee295-31d2-495b-b206-40ffc5f25133.gif)

  > Full-featured 4 nodes demo sandbox can be created using pre-configured vagrant & terraform templates.

  </details>

* [**Versatile Scenario**](f#):  Monitor existing RDS, Run docker template apps, Toolset for data apps & vis/analysis.
  <details><summary>Docker Applications, Data Toolkits, Visualization Data Apps</summary>

  ![APP](https://user-images.githubusercontent.com/8587410/198838829-f0ea4af2-d33f-4978-a31a-ed81897aa8d1.gif)

  > If your software requires a PostgreSQL, Pigsty may be the easiest way to get one.
  </details>


* [**Production Ready**](#): Ready for large-scale production environment and proven in real-world scenarios.

  <details><summary>Overview Dashboards for a Huge Production Deployment</summary>

  ![OVERVIEW](https://user-images.githubusercontent.com/8587410/198838841-b0796703-03c3-483b-bf52-dbef9ea10913.gif)

  > A real-world Pigsty production deployment with 240 nodes, 13kC / 100T, 500K TPS , 3+ years.

    </details>

* [**Cost Saving**](#): Save 50% - 95% compare to Public Cloud RDS. Create as many clusters as you want for free!

  <details><summary>Price Reference for EC2 / RDS Unit  ($ per  core · per month)</summary>

  | Resource       | **Node Price** |
  |----------------| ---------------|
  | AWS EC2 C5D.METAL 96C 200G                             | 11 ~ 14        |
  | Aliyun ECS 2xMem Series Exclusive                      | 28 ~ 38        |
  | IDC Self-Hosting: Dell R730 64C 384G x PCI-E SSD 3.2TB | 2.6            |
  | IDC Self-Hosting: Dell R730 40C 64G (China Mobile)     | 3.6            |
  | UCloud VPC 8C / 16G Exclusive                          | 3.3            |
  | **⬆️ EC2  /  RDS⬇️**                                   |  **RDS Price** |
  | Aliyun RDS PG 2x Mem                                   | 36 ~ 56        |
  | AWS RDS PostgreSQL db.T2 (4x) / EBS                    | 60             |
  | AWS RDS PostgreSQL db.M5 (4x) / EBS                    | 84             |
  | AWS RDS PostgreSQL db.R6G (8x) / EBS                   | 108            |
  | AWS RDS PostgreSQL db.M5 24xlarge (96C 384G)           | 182            |
  | Oracle Licenses                                        | 1300           |

  > AWS Price [Calculator](https://calculator.amazonaws.cn/#/): You can run RDS service with a dramatic cost reduction with EC2 or IDC.

  </details>

Check [**FEATURES**](https://github.com/Vonng/pigsty/wiki/Overview) for detail.



--------

## Getting Started

Get a fresh Linux x86_64 EL7/8/9 node with nopass `sudo` & `ssh` access:

```bash
bash -c "$(curl -fsSL http://download.pigsty.cc/get)" && cd ~/pigsty   
./bootstrap  && ./configure && ./install.yml # install latest pigsty
```

> Build & Test on centos7.9, rocky8.6, rocky9.0. Compatible with RHEL, Oracle, Alma, etc...

Now you have a battery-included Postgres on port **5432** and infra web services available on port **80**.

Check [Installation](https://github.com/Vonng/pigsty/wiki/Installation) & [Configure](https://github.com/Vonng/pigsty/wiki/Configuration) for detail.




--------

## More Clusters

After installation, the node can be used as a control center & infra provider to manage, deploy & monitor more nodes & database clusters. To deploy a HA Postgres Cluster with streaming replication, [define](https://github.com/Vonng/pigsty/blob/master/pigsty.yml#L157) a new cluster on `all.children.pg-test` of [`pigsty.yml`](https://github.com/Vonng/pigsty/blob/master/pigsty.yml):

```yaml
pg-test:
  hosts:
    10.10.10.11: {pg_seq: 1, pg_role: primary}
    10.10.10.12: {pg_seq: 2, pg_role: replica}
    10.10.10.13: {pg_seq: 3, pg_role: replica}
  vars:  { pg_cluster: pg-test }
```

Then create it with built-in playbooks:

```bash
./nodes.yml -l pg-test   # init nodes of pg-test 
./pgsql.yml -l pg-test   # init pg cluster pg-test
```

You can deploy different kinds of instance roles such as primary, replica, offline, delayed, sync standby, and different kinds of clusters such as standby clusters, Citus clusters, and even Redis clusters & YMatrix clusters. Check [playbook](https://github.com/Vonng/pigsty/wiki/Playbook) & [admin](https://github.com/Vonng/pigsty/wiki/Administration) for details.



--------

## About

> Pigsty (/ˈpɪɡˌstaɪ/) is the abbreviation of "PostgreSQL In Graphic STYle."

Official Site: https://pigsty.cc/en/  https://pigsty.cc/zh/

WeChat Group: Search `pigsty-cc` to join the WeChat group.

Telegram: https://t.me/joinchat/gV9zfZraNPM3YjFh

Discord: https://discord.gg/wDzt5VyWEz

Author: [Vonng](https://vonng.com/en) ([rh@vonng.com](mailto:rh@vonng.com))

License: [Apache 2.0 License](LICENSE)

Copyright 2018-2022 rh@vonng.com
