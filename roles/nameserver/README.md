# Nameserver (ansible role)

This role will provision nameserver on given hosts
* handler DNS request on 53
* serve dynamic DNS records via dnsmasq


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
nameserver : Copy dnsmasq /etc/dnsmasq.d/config	TAGS: [dnsmasq, meta]
nameserver : Add dynamic dns records to meta	TAGS: [dnsmasq, meta]
nameserver : Launch meta dnsmasq service		TAGS: [dnsmasq, meta]
nameserver : Wait for meta dnsmasq online		TAGS: [dnsmasq, meta]
nameserver : Register consul dnsmasq service	TAGS: [dnsmasq, meta]
nameserver : Reload consul						TAGS: [dnsmasq, meta]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
dns_records:
  - 10.10.10.10 pigsty y.pigsty yum.pigsty

# - reference : dcs metadata - #
dcs_type: consul                  # default dcs server type: consul
consul_check_interval: 15s        # default service check interval
consul_check_timeout:  1s         # default service check timeout
```