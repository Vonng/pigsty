# Nameserver (ansible role)

This role will provision nameserver on given hosts
* handler DNS request on 53
* serve dynamic DNS records via dnsmasq


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
Make sure dnsmasq package installed		  TAGS: [dnsmasq]
Copy dnsmasq /etc/dnsmasq.d/config		  TAGS: [dnsmasq]
Add dynamic dns records to meta			  TAGS: [dnsmasq]
Launch meta dnsmasq service				  TAGS: [dnsmasq]
Wait for meta dnsmasq online			  TAGS: [dnsmasq]
Register consul dnsmasq service			  TAGS: [dnsmasq]
Reload consul							  TAGS: [dnsmasq]
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