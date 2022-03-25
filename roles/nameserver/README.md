# Nameserver (ansible role)

This role will provision nameserver on given hosts
* handler DNS request on port 53
* serve dynamic DNS records via dnsmasq


### Tasks

[tasks/main.yml](tasks/main.yml)

```yaml
 Make sure dnsmasq package installed	TAGS: [infra-svcs, nameserver]
 Copy dnsmasq /etc/dnsmasq.d/config	TAGS: [infra-svcs, nameserver]
 Add dynamic dns records to meta	TAGS: [infra-svcs, nameserver]
 Launch meta dnsmasq service	TAGS: [infra-svcs, nameserver]
 Wait for meta dnsmasq online	TAGS: [infra-svcs, nameserver]
 Register consul dnsmasq service	TAGS: [infra-svcs, nameserver]
 Reload consul	TAGS: [infra-svcs, nameserver]
```

### Default variables

[defaults/main.yml](defaults/main.yml)

```yaml
#-----------------------------------------------------------------
# NAMESERVER
#-----------------------------------------------------------------
dns_records: [ ]                      # dynamic dns record resolved by dnsmasq

#-----------------------------------------------------------------
# DCS (Reference)
#-----------------------------------------------------------------
service_registry: consul              # none | consul | etcd | both
```