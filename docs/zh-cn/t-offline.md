# 离线安装


Pigsty是一个复杂的软件系统，为了确保系统的稳定，Pigsty会在初始化过程中从互联网下载所有依赖的软件包并建立[**本地仓库**](v-infra#repo) （本地Yum源）。

所有依赖的软件总大小约1GB左右，下载速度取决于用户的网络情况。尽管Pigsty已经尽量使用镜像源以加速下载，但少量包的下载仍可能受到防火墙的阻挠，可能出现非常慢的情况。用户可以通过 [**`proxy_env`**](v-infra.md#proxy_env) 配置项设置下载代理，以完成首次下载。

如果您使用了不同于CentOS 7.8的操作系统，通常建议用户采用完整的在线下载安装流程。并在首次初始化完成后缓存下载的软件，参见[**制作离线安装包**](#制作离线安装包)。

如果您希望跳过漫长的下载过程，或者执行控制的元节点**没有互联网访问**，则可以考虑下载预先打包好的**离线安装包**。



## 离线安装包的内容

为了**快速**拉起Pigsty，**建议**使用离线下载软件包并上传的方式完成安装。

离线安装包收纳了本地Yum源的所有软件包。默认情况下，Pigsty会在[基础设施初始化](p-meta)时创建本地Yum源，

```
{{ repo_home }}
  |---- {{ repo_name }}.repo
  ^---- {{ repo_name}}/repo_complete
  ^---- {{ repo_name}}/**************.rpm
```

默认情况下，`{{ repo_home }}` 是Nginx静态文件服务器的根目录，默认为`/www`，`repo_name`是自定义的本地源名称，默认为`pigsty`

以默认情况为例，`/www/pigsty` 目录包含了所有 RPM 软件包，离线安装包实际上就是 `/www/pigsty` 目录的压缩包 。

离线安装包的原理是，Pigsty在执行基础设施初始化的过程中，会[检查](https://github.com/Vonng/pigsty/blob/master/roles/repo/tasks/main.yml#L49)本地Yum源相关文件是否已经存在。如果已经存在，则会跳过下载软件包及其依赖的过程。

检测所用的标记文件为`{{ repo_home }}/{{ repo_name }}/repo_complete`，默认情况下为`/www/pigsty/repo_complete`，如果该标记文件存在，（通常是由Pigsty在创建本地源之后设置），则表示本地源已经建立完成，可以直接使用。否则，Pigsty会执行常规的下载逻辑。下载完毕后，您可以将该目录压缩复制归档，用于加速其他环境的初始化。



## 沙箱环境

### 下载离线安装包

Pigsty自带了一个沙箱环境，沙箱环境的离线安装包默认放置于[`files`](https://github.com/Vonng/pigsty/tree/master/files)目录中，可以从[Github Release](https://github.com/Vonng/pigsty/releases)页面下载。

```bash
curl -SL https://github.com/Vonng/pigsty/releases/download/${VERSION}/pkg.tgz -o dist/${VERSION}/pkg.tgz
```

Pigsty的官方CDN也提供最新版本的`pkg.tgz`下载，只需要执行以下命令即可。

```bash
make downlaod
curl http://pigsty-1304147732.cos.accelerate.myqcloud.com/pkg.tgz -o files/pkg.tgz
```

### 上传离线安装包

使用Pigsty沙箱时，下载离线安装至本地`files`目录后，则可以直接使用 Makefile 提供的快捷指令`make copy-pkg`上传离线安装包至**元节点**上。

使用 `make upload`，也会将本地的离线安装包（Yum缓存）拷贝至元节点上。

```shell
# upload rpm cache to meta controller
upload:
	ssh -t meta "sudo rm -rf /tmp/pkg.tgz"
	scp -r files/pkg.tgz meta:/tmp/pkg.tgz
	ssh -t meta "sudo mkdir -p /www/pigsty/; sudo rm -rf /www/pigsty/*; sudo tar -xf /tmp/pkg.tgz --strip-component=1 -C /www/pigsty/"
```

### 制作离线安装包

使用 Pigsty 沙箱时，可以通过 `make cache` 将沙箱中元节点的缓存制为离线安装包，并拷贝到本地。

```bash
# cache rpm packages from meta controller
cache:
	rm -rf pkg/* && mkdir -p pkg;
	ssh -t meta "sudo tar -zcf /tmp/pkg.tgz -C /www pigsty; sudo chmod a+r /tmp/pkg.tgz"
	scp -r meta:/tmp/pkg.tgz files/pkg.tgz
	ssh -t meta "sudo rm -rf /tmp/pkg.tgz"
```



## 在生产环境离线安装包

在生产环境使用离线安装包前，您必须确保生产环境的操作系统与制作该**离线安装包**的机器**操作系统一致**。Pigsty提供的离线安装包默认使用CentOS 7.8。

使用不同操作系统版本的离线安装包**可能**会出错，也可能不会，我们强烈建议不要这么做。

如果需要在其他版本的操作系统（例如CentOS7.3，7.7等）上运行Pigsty，建议用户在安装有同版本操作系统的沙箱中完整执行一遍初始化流程，**不使用离线安装包**，而是直接从上游源下载的方式进行初始化。对于没有网络访问的生产环境元节点而言，制作离线软件包是至关重要的。

常规初始化完成后，用户可以通过`make cache`或手工执行相关命令，将特定操作系统的软件缓存打为离线安装包。供生产环境使用。

从初始化完成的本地元节点构建离线安装包：

```bash
tar -zcf /tmp/pkg.tgz -C /www pigsty     # 制作离线软件包
```

在生产环境使用离线安装包与沙箱环境类似，用户需要将`pkg.tgz`复制到元节点上，然后将离线安装包解压至目标地址。

这里以默认的 `/www/pigsty` 为例，将压缩包中的所有内容（RPM包，repo_complete标记文件，repodata 源的元数据库等）解压至目标目录`/www/pigsty`中，可以使用以下命令。

```bash
mkdir -p /www/pigsty/
sudo rm -rf /www/pigsty/*
sudo tar -xf /tmp/pkg.tgz --strip-component=1 -C /www/pigsty/
```

