# Vagrant Provision Guide

If you wish to run pigsty on your laptop, consider using vagrant and virtualbox as vm provisioner

1. Install  [vagrant](https://vagrantup.com/), [virtualbox](https://www.virtualbox.org/) and [ansible](https://www.ansible.com/) on your computer. for example:

  ```bash
brew install virtualbox vagrant ansible 	# MacOS, other may not work this way
  ```

2. Use vagrant with [`Vagrantfile`](vagrant/Vagrantfile), it will provision 4 nodes (via [virtualbox](https://www.virtualbox.org/)) for this project.

  ```bash
make up     # pull up vm nodes. alternative: cd vagrant && vagrant up
  ```

3. Setup nopass ssh from your host to vm nodes

  ```bash
make ssh		# cd vagrant && vagrant ssh-config > ~/.ssh/pigsty_config
  ```

4. There are some vagrant shortcuts defined in [Makefile](Makefile) 

```bash
make				# launch cluster
make new    # create a new pigsty cluster
make dns		# write pigsty dns record to your /etc/hosts (sudo required)
make ssh		# write ssh config to your ~/.ssh/config
make clean	# delete current cluster
make cache	# copy local yum repo packages to your pigsty/pkg
```





## Vagrant使用教程

如果您希望在本地环境运行Pigsty示例，可以考虑使用 [vagrant](https://vagrantup.com/)与[virtualbox](https://www.virtualbox.org/)初始化本地虚拟机。



1. 在宿主机上安装  [vagrant](https://vagrantup.com/), [virtualbox](https://www.virtualbox.org/) 与[ansible](https://www.ansible.com/)（可选）

   具体安装方式因平台而异，请参照软件官网文档进行，以MacOS为例，可以使用[homebrew](https://brew.sh/)一键安装：

  ```bash
brew install virtualbox vagrant ansible 	# MacOS命令行
  ```

2. 在项目主目录执行`make up`，系统会使用 [`Vagrantfile`](vagrant/Vagrantfile)中的定义拉起四台虚拟机。

  ```bash
make up     # 拉起所有节点，也可以通过进入vagrant目录执行vagrant up实现
  ```

3. 配置宿主机到虚拟机的SSH免密访问

  ```bash
make ssh		# 等价于执行 cd vagrant && vagrant ssh-config > ~/.ssh/pigsty_config
  ```

4. 在 [Makefile](Makefile) 中定义了一些vagrant快捷方式

```bash
make				# 启动集群
make new    # 销毁并创建新集群
make dns		# 将Pigsty域名记录写入本机/etc/hosts （需要sudo权限）
make ssh		# 将虚拟机SSH配置信息写入 ~/.ssh/config
make clean	# 销毁现有本地集群
make cache	# 制作离线安装包，并拷贝至宿主机本地，加速后续集群创建
make upload # 将离线安装缓存包 pkg.tgz 上传并解压至默认目录 /www/pigsty
```



