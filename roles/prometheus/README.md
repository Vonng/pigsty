# Meta (ansible role)

This role will provision a meta node with following tasks:
* Re-init nginx server
* Nginx exporter
* Dnsmasq setup
* Prometheus setup
* Grafana setup


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Install prometheus and alertmanager		  TAGS: [prometheus_install]
Wipe out prometheus config dir			  TAGS: [prometheus_clean]
Wipe out existing prometheus data		  TAGS: [prometheus_clean]
Recreate prometheus data dir			  TAGS: [prometheus_config]
Copy /etc/prometheus configs			  TAGS: [prometheus_config]
Copy /etc/prometheus opts				  TAGS: [prometheus_config]
Overwrite prometheus scrape_interval	  TAGS: [prometheus_config]
Overwrite prometheus evaluation_interval  TAGS: [prometheus_config]
Overwrite prometheus scrape_timeout		  TAGS: [prometheus_config]
Overwrite prometheus pg metrics path	  TAGS: [prometheus_config]
Launch prometheus service				  TAGS: [prometheus_launch]
Launch alertmanager service				  TAGS: [prometheus_launch]
Wait for prometheus online				  TAGS: [prometheus_launch]
Wait for alertmanager online			  TAGS: [prometheus_launch]
Copy prometheus service definition		  TAGS: [prometheus_register]
Copy alertmanager service definition	  TAGS: [prometheus_register]
Reload consul to register prometheus	  TAGS: [prometheus_register]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
prometheus_scrape_interval: 15s               # global scrape & evaluation interval
prometheus_scrape_timeout: 5s                 # scrape timeout
prometheus_metrics_path: /metrics             # default metrics path (only for job 'pg')
prometheus_data_dir: /var/lib/prometheus/data # prometheus data dir
prometheus_retention: 90d                     # how long to keep
prometheus_reload: false                      # reload prometheus instead of recreate it

# - reference : dcs metadata - #
dcs_type: consul                  # default dcs server type: consul
consul_check_interval: 15s        # default service check interval
consul_check_timeout:  1s         # default service check timeout
```