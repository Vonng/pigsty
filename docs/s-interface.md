## User Interface

Pigsty GUI is viable after [installation](s-install.md). 

http://g.pigsty -> http://10.10.10.10:80 (nginx) -> http://10.10.10.10:3000 (grafana)

Visit `http://<node_ip>:3000` to browse Pigsty [home](http://demo.pigsty.cc/d/home) (username: `admin`, password: `pigsty`)


## Web Services

Pigsty will provide services to the public through a series of ports. 
Nginx is the uniform access-point for all web service.


| Component | Port | Default Domain | Description |
| :-----------: | :--: | :----------: | ------------------------------- |
| Grafana | 3000 | `g.pigsty` | Pigsty Monitoring System GUI |
| Prometheus | 9090 | `p.pigsty` | Monitoring Timing Database |
| AlertManager | 9093 | `a.pigsty` | Alarm aggregation management component |
| Consul | 8500 | `c.pigsty` | Distributed Configuration Management, Service Discovery |
| Consul DNS | 8600 | - | Consul-provided DNS services |
| Nginx | 80 | `pigsty` | Entry proxy for all services |
| Yum Repo | 80 | `yum.pigsty` | Local Yum sources |
| Haproxy Index | 80 | `h.pigsty` | Access proxy for all Haproxy management interfaces |
| NTP | 123 | `n.pigsty` | The NTP time server used uniformly by the environment |
| Dnsmasq | 53 | - | The DNS name resolution server used by the environment |


![](_media/infra.svg)


Users can configure their own existing domain names for these services,
or use the `make dns` shortcut to write the default domain names to `/etc/hosts`.

Users can still access most services directly using the IP:Port method,
for example, the entry point to the Pigsty monitoring system is the management node IP+3000 port.

!> Note that if Consul is used as the DSC, the Consul UI **must** be accessed through domain names and proxy by nginx. Consul listens on port 127.0.0.1, it's a deliberate design due to security reasons: Consul stores sensitive metadata that should not expose to the public.



## Demo

Pigsty provides a public demo at: [http://demo.pigsty.cc](http://demo.pigsty.cc)

Because the demo instance is an empty virtual machine with 1 core and 1GB, the display is thin, so please refer to the actual effect.


<iframe style="height:1160px" src="http://demo.pigsty.cc/d/home"></iframe>

