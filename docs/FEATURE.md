# Features

Me-Better OpenSource RDS Alternative, with:
- Battery-Included PostgreSQL Distribution, with PostGIS, TimescaleDB, Citus ...
- Ulitemate observability, powered by prometheus & grafana family
- Self-healing high-availbility, powered by patroni, haproxy and etcd
- Auto-Configured PITR, powered by pgbackrest and optional minio
- Declaretive API, Database-as-Code implmented with Ansible playbooks
- Versatile Usecases, Monitoring existing RDS, Run Docker Apps & Data Apps
- Easy-to-Use, One cmd handle them all: Provisioning IaaS with Terraform/Vagrant


![pigsty-distro](https://user-images.githubusercontent.com/8587410/206971964-0035bbca-889e-44fc-9b0d-640d34573a95.gif)


## High-Availability

Auto-Pilot Postgres with idempotent instances & services, self-healing from failures!
  
  High-Availability PostgreSQL Powered by Patroni & HAProxy
  
  ![pigsty-ha](https://user-images.githubusercontent.com/8587410/206971583-74293d7b-d29a-4ca2-8728-75d50421c371.gif)

  > Self-healing on hardware failures: Failover impact on primary < 30s, Switchover impact < 1s
  

## Ultimate Observability


  Unparalleled monitoring system based on modern open-source best-practice!!
  
  Observability powered by Grafana, Prometheus & Loki

  ![DASHBOARD](https://user-images.githubusercontent.com/8587410/198838834-1bd30b7e-47c9-4e35-90cb-5a75a2e6f6c6.jpg)

  > 3K+ metrics on 30+ dashboards, Check [http://demo.pigsty.cc](http://demo.pigsty.cc) for a live demo!

  

## Database as Code

  Declarative config with idempotent playbooks. WYSIWYG and GitOps made easy!
  
  Define & Create a HA PostgreSQL Cluster in 10 lines of Code

  ![pigsty-iac](https://user-images.githubusercontent.com/8587410/206972039-e13746ab-72ae-4cab-8de7-7b2ef543f3e5.gif)

  > Create a 3-node HA PostgreSQL with 10 lines of config and one command!


## IaaS Provisioning

  Bare metal or VM, Cloud or On-Perm, One-Click provisioning with Vagrant/Terraform

  Pigsty 4-nodes sandbox on Local Vagrant VM or AWS EC2

  ![pigsty-sandbox](https://user-images.githubusercontent.com/8587410/206972073-f204fb7a-b91c-4f50-9d5e-3104ea2e7d70.gif)

  > Full-featured 4 nodes demo sandbox can be created using pre-configured vagrant & terraform templates.

  

## Versatile Scenario

  Monitor existing RDS, Run docker template apps, Toolset for data apps & vis/analysis.

  Docker Applications, Data Toolkits, Visualization Data Apps

  ![APP](https://user-images.githubusercontent.com/8587410/198838829-f0ea4af2-d33f-4978-a31a-ed81897aa8d1.gif)

  > If your software requires a PostgreSQL, Pigsty may be the easiest way to get one.
  


## Production Ready

  Ready for large-scale production environment and proven in real-world scenarios.

  Overview Dashboards for a Huge Production Deployment

  ![OVERVIEW](https://user-images.githubusercontent.com/8587410/198838841-b0796703-03c3-483b-bf52-dbef9ea10913.gif)

  > A real-world Pigsty production deployment with 240 nodes, 13kC / 100T, 500K TPS , 3+ years.

    

## Cost Saving

: Save 50% - 95% compare to Public Cloud RDS. Create as many clusters as you want for free!

  Price Reference for EC2 / RDS Unit  ($ per  core · per month)

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

  

## Security

On-Perm Deployment, Self-signed CA, Full SSL Support, PITR with one-command.

PITR with Pgbackrest

  ```bash
  pg-backup                               # make a full/incr backup
  pg-pitr                                 # restore to wal archive stream end (e.g. used in case of entire DC failure)
  pg-pitr -i                              # restore to the time of latest backup complete (not often used)
  pg-pitr --time="2022-12-30 14:44:44+08" # restore to specific time point (in case of drop db, drop table)
  pg-pitr --name="my-restore-point"       # restore TO a named restore point create by pg_create_restore_point
  pg-pitr --lsn="0/7C82CB8" -X            # restore right BEFORE a LSN
  pg-pitr --xid="1234567" -X -P           # restore right BEFORE a specific transaction id, then promote
  pg-pitr --backup=latest                 # restore to latest backup set
  pg-pitr --backup=20221108-105325        # restore to a specific backup set, which can be checked with pgbackrest info


  ```

  > Check [Backup & PITR](https://github.com/Vonng/pigsty/wiki/Backup-and-PITR) for details

