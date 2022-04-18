## Why use Pigsty?

> Our philosophy is: use the **good database**, **use the good** database so that there is no hard-to-use database in the world!


The database is the core component of an information system, a relational database is the absolute mainstay of the database, and PostgreSQL is the world's most advanced open-source relational database.

PG provides a perfect enough database kernel, but it is not so simple to really use it well, and we help users to do that.



## User's Demand

What kind of database do traditional enterprises, especially SMEs, need for information technology? Is it a distributed cloud-native lake warehouse integrated flow batch time hyper-converged HTAP database?

No, most of the enterprise database needs, even Excel will be enough to solve! The pain point does not lie in the database kernel cattle, but whether the user can use it!

99% of enterprises, the complete life cycle of data needs, **singleton PostgreSQL is sufficient!** 



## Requirements

> Software swallows the world, and open source swallows software. Cloud vendors whoring out open source, but not seeing the mantis, will eventually be dried out by multi-cloud deployments.

It's one thing to build a personal toy demo to use a database, it's another thing to deploy and maintain a database in a production environment: installation and deployment, operation and maintenance management, supporting facilities, platform building, service access, high availability, failover, load balancing, connection pooling, database and table splitting, monitoring, logging, auditing, backup, recovery, upgrade strategy, schema changes ...... There are countless practical problems to solve, not just `yum install postgresql14* && systemctl start postgresql`.

PostgreSQL already provides a perfect enough database kernel, but just as Linux users are directly exposed to operating system distributions such as RedHat, SUSE, and Ubuntu, not the Linux kernel. Users need a complete solution -- a database distribution, not just a database kernel.

If PostgreSQL, the database kernel, is an engine, then what users really need is the whole car, the complete, battery-included solution. What we build is such a car: stable and reliable, polished and verified in a long-time production environment; self-driving, with intelligent situational awareness.

What's more, Pigsty is completely **open-source and free**! Pigsty can reduce the comprehensive cost of database ownership by 50% to 80% while providing a similar or even better experience than cloud vendors' RDS.




## Product Position

###  Battery-included distribution

> RedHat for Linux

* Pigsty is packaged with the latest PostgreSQL kernel (14), the powerful geospatial plugin PostGIS3.2, the temporal database plugin TimescaleDB2.6, and the distributed extension plugin Citus10, and hundreds of functional extensions, all installed with a single click and ready to use battery-included.
* Pigsty integrates a complete large-scale database monitoring and control solution: Grafana, Prometheus, Loki, Ansible, CMDB, and can be used directly as a production application runtime to monitor and manage other databases and applications.
* Pigsty integrates the most popular tools in the data analysis ecosystem: Jupyter, Echarts, Grafana, PostgREST, Postgres, and allows you to develop interactive data applications and data visualizations in a low-code manner. Produce prototypes quickly, and share, demonstrate and deliver in a standard way.



### Easy-to-use Developer Toolkit

> HashiCorp for Database!

* Pigsty is designed with Infra as Data in mind, users describe what kind of database cluster they want and Pigsty automatically creates it for you! Just like Kubernetes!
* Pigsty comes with the ultimate observability, designing monitoring systems with a BI mindset, from the topmost global insight to the most detailed every object, to get real-time data to support decision making.

* Pigsty provides flexible and rich deployment support, local sandbox, cloud, and multi-cloud deployments. Both high-spec physical machines and 1-core 1G virtual machines can run, keeping production, pre-release, development, and test environments highly consistent.

### Smart and cost-saving SRE solutions

> Alternative for RDS!

* Highly available database clusters: Pigsty integrates proven production-grade highly available database architecture solutions: master-slave offsite disaster recovery, self-healing failures, automatic high availability switchover, self-contained connection pooling, and load balancer, providing a distributed database like experience.
* Pigsty provides a complete backup solution with one-click deployment of autopilot highly available master-slave clusters and self-healing hardware failures, greatly simplifying O&M work. Cold backup and delayed slave can effectively deal with all kinds of software failures and human failures to ensure stable system operation.

* Pigsty can also be used as a complete SRE solution: host monitoring, application deployment, and will gradually add the deployment and monitoring of other databases: Redis/Greenplum/Kafka/Minio, or support other SaaS services, produce POC, deliver demos, etc.



## VS Cloud Database RDS

Cloud Database/RDS, another "battery-included" solution, does not deliver nearly enough to satisfy the professional user:  

**High cost**

  * The cost of RDS is **5 to 10 times higher** than IDC hosting and **2 to 3 times higher** even than cloud VMs.
  * The price of RDS may be advantageous relative to commercial databases, but it is still ridiculously high in front of self-build.

**Life is not your choice**.

  * Cloud vendors can access all types of your data, and many are not truly neutral third-party operators.
  * Cloud vendor failures are not uncommon, and the only compensation you can have is usually a poor hourly voucher.

**Limited functionality**

  * You don't have true superuser access to RDS and some advanced features are not available.
  * 'Stream replication', and 'high availability' which should be standard are often sold as value-added items.

**Limited experience**

  * Cloud vendor RDS provides observability often with only a few sporadic monitoring metrics, lacking global integration and God's perspective.
  * Installation, deployment, access, and use still require a lot of UI interaction and manipulation.
