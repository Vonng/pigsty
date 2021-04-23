# Quick Start

### 1. Prepare 1~4 node

* CentOS 7  (7.8 fully tested)
* 2 Core / 2 GB at least
* have root or sudo access
 

### 2. Get Pigsty Source Code

Download and extract pigsty source to ~/pigsty

```bash
curl http://pigsty-1304147732.cos.accelerate.myqcloud.com/v${VERSION-0.9}/pigsty.tgz -o /tmp/pigsty.tgz && rm -rf ${HOME}/pigsty && tar -xf /tmp/pigsty.tgz -C ${HOME} && cd ~/pigsty
```

Download offline installation packages (centos7.8)

> It's optional if you have internet access on meta node  

```bash
cd ~/pigsty && bin/get_pkg
```


### 3. Boot meta node

Install ansible on meta node from Internet (or from /tmp/pkg.tgz)

```bash
sudo bin/boot
``` 

### 4. Ready to work

* init infrastructure on meta node with `infra.yml`
* init postgres clusters on other node with `pgsql.yml`
 
```bash
./infra.yml                 # setup infrastructure and meta pgsql cluster pg-meta
./pgsql.yml -l pg-test      # create new clusters pg-test on 3 other nodes (optional)     
``` 