## 用户界面

完成安装后，可以通过浏览器访问Pigsty提供的图形用户界面。

http://g.pigsty -> http://10.10.10.10:80 (nginx) -> http://10.10.10.10:3000 (grafana)

访问 `http://<node_ip>:3000` 即可浏览 Pigsty [主页](http://demo.pigsty.cc/d/home) (用户名: `admin`, 密码: `pigsty`)

您可以访问 [http://demo.pigsty.cc](http://demo.pigsty.cc) 来查看公开Pigsty Demo，并浏览**Pigsty监控系统**提供的功能。


## Web服务


Pigsty会通过一系列端口对外提供服务，Web服务会通过Nginx 80端口统一访问。

|     组件      | 端口 |   默认域名   | 说明                            |
| :-----------: | :--: | :----------: | ------------------------------- |
|    Grafana    | 3000 |  `g.pigsty`  | Pigsty监控系统图形界面          |
|  Prometheus   | 9090 |  `p.pigsty`  | 监控时序数据库                  |
|  Loki         | 3100 |  `l.pigsty`  | 日志收集服务端（无界面） |
| AlertManager  | 9093 |  `a.pigsty`  | 报警聚合管理组件                |
|    Consul     | 8500 |  `c.pigsty`  | 分布式配置管理，服务发现        |
|  Consul DNS   | 8600 |      -       | Consul提供的DNS服务             |
|     Nginx     |  80  |   `pigsty`   | 所有服务的入口代理              |
|   Yum Repo    |  80  | `yum.pigsty` | 本地Yum源                       |
| Haproxy Index |  80  |  `h.pigsty`  | 所有Haproxy管理界面的访问代理   |
|      NTP      | 123  |  `n.pigsty`  | 环境统一使用的NTP时间服务器     |
|    Dnsmasq    |  53  |      -       | 环境统一使用的DNS域名解析服务器 |


![](../_media/ARCH.gif)


用户可以为这些服务配置自己已有的域名，或使用`make dns`快捷方式将默认的域名写入`/etc/hosts`。
用户仍然可以使用 IP:Port 的方式直接访问大部分服务，例如，Pigsty监控系统的入口即为元节点IP+3000端口。

!> 注意，如果使用了Consul作为DSC，Consul UI **必须** 通过Nginx域名的方式访问。Consul监听127.0.0.1端口，这是一个出于安全性考量而特意做出的设计：Consul包含了敏感的元数据，不宜直接对外暴露。





