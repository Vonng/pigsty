# Bootstrap Guide



## Offline Installation

Sometimes you may not have Internet access. Offline installtion is prepared for this. (But currently only Cent 7 is supported)

It may takes around 5m~30m to download all packages (1GB) according to your network condition. Consider using a local [http proxy](group_vars/dev.yml), and don't forget to make a package cache via  `make cache` after bootstrap. 

You can also download a pre-made packages cache [pkg.tgz](), but this only works for CentOS 7.6. Download pkg.tgz and put it under your meta local yum repo dir, (`/www/pigsty` by default).

Another tricky thing is that if you wish to run playbooks on meta node that does not have `ansible` installed. You may have to install it from cache via local file repo. Refer [this](roles/repo/templates/bootstrap.sh.j2)





# 离线安装手册

生产环境因为各种限制无法提供互联网访问是非常常见的现象。因此Pigsty提供了离线安装模式（目前仅支持CentOS 7.6）。

Pigsty在第一次执行环境初始化时，会检查是否已经存在离线安装包缓存，如果存在则会直接从离线安装包中建立本地源。离线安装包可以通过以下两种方式获取：

* 下载预打包好的离线安装包，将其手工上传至目标环境中控机上。
* 在有互联网访问的同操作系统机器下执行一次pigsty初始化，然后 `make cache` 构建缓存，将其手工上传至目标环境中控机上。

执行Pigsty需要用到Ansible，如果您的操作机器上未安装Ansible，则可以通过本地文件Yum源的方式从离线安装包中安装ansible。

例如：

```bash
# 将离线安装包拷贝至中控机并解压至目标位置
scp pkg.tgz meta:/tmp/pkg.tgz
ssh meta
mkdir /www && tar -xf /tmp/pkg.tgz -C /www

# 将本地文件yum源信息写入yum源列表
cat > /etc/yum.repos.d/local.repo <<-'EOF'
[local]
name=local
baseurl=file:///www/pigsty
gpgcheck=0
enabled=1
EOF

# 使用本地源安装ansible
yum install -y ansible
```

