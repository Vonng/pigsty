# Prometheus

* Location: node0 (meta)
* Binary Path: `/bin/prometheus`
* Data Directory: `/var/lib/prometheus/data`
* Config Directory: `/etc/prometheus`

## TL;DR

How to reload prometheus configuration

```bash
ssh node0
sudo su
cd /etc/prometheus

bin/check
bin/reload
```

## Files

* [`prometheus.yml`](prometheus.yml) Major prometheus configuration
* [`alertmanager.yml`](alertmanager.yml) Major alertmanager configuration
* [`rules`](rules/) Prometheus rules
  * [`pgsql.yml`](rules/alert.yaml) postgres record and alert rules 
  * [`node.yaml`](rules/node.yml) node record and alert rules


