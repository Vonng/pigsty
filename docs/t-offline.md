# Offline Installation

Pigsty downloads all dependent packages from the Internet and creates [**local Yum repo**](v-infra#repo) during initialization.

The total size of all the dependent software is about 1GB or so. Although Pigsty has tried to use mirror repos as much as possible to speed up the download, the download of a small number of packages may still be blocked by firewalls and may appear very slow. You can set the download proxy to complete the first download by using the [**`proxy_env`**](v-infra.md#proxy_env) config entry.

If you are using an OS other than CentOS 7.8, it is recommended that you use the full online download and installation process. And cache the downloaded software after the first initialization is complete. See [**Making an offline pkg**](#Make-offline-pkg).

If you wish to skip the extended download process, or if the execution control meta-node **does not have Internet access**, consider downloading a pre-packaged **offline pkg**.



## Contents

To **quickly** pull up Pigsty, it is **recommended** to use the offline package and upload method to complete the installation.

The offline pkg includes all packages from the local Yum repo. Pigsty is installed at [Infra Init](p-infra.md) when the local Yum repo is created by default.

```
{{ repo_home }}
  |---- {{ repo_name }}.repo
  ^---- {{ repo_name}}/repo_complete
  ^---- {{ repo_name}}/**************.rpm
```

`{{ repo_home }}` is the root dir of the Nginx static file server, which defaults to `/www`, and `repo_name` is a custom local source name, which defaults to `pigsty`.

The `/www/pigsty` dir contains all RPM packages, and the offline pkg is actually a zip archive of the `/www/pigsty` dir.

The principle of the offline pkg is that Pigsty [checks](https://github.com/Vonng/pigsty/blob/master/roles/repo/tasks/main.yml#L49) if the local Yum repo-related files already exist during the execution of the infra initialization. If they already exist, download the package, and its dependencies are skipped.

The marker file used for the check is `{{ repo_home }}/{{ repo_name }}/repo_complete`, which defaults to `/www/pigsty/repo_complete`. If this marker file exists, it means that the local YUM repo has been created. Otherwise, Pigsty will perform the usual download logic. Once the download is complete, you can archive a compressed copy of the dir for accelerating the initialization of other environments.





## Sandbox Environment

### Downloading offline installers

Pigsty comes with a sandbox. The offline installer for the sandbox is placed in the [`files`](https://github.com/Vonng/pigsty/tree/master/files) dir by default and can be downloaded from the [Github Release](https://github.com/Vonng/pigsty/releases) page.

```bash
curl -SL https://github.com/Vonng/pigsty/releases/download/${VERSION}/pkg.tgz -o dist/${VERSION}/pkg.tgz
```

Pigsty's official CDN also provides the latest version of `pkg.tgz` for download. Just execute the following command.

```bash
make downlaod
curl http://pigsty-1304147732.cos.accelerate.myqcloud.com/pkg.tgz -o files/pkg.tgz
```



### Upload offline pkg

When using the Pigsty sandbox, after downloading the offline pkg to the dir of the local `files`, you can directly upload the offline pkg to the **meta node** using the shortcut command `make copy-pkg` provided by Makefile.

Using ``make upload`` will also copy the local offline pkg (Yum cache) to the meta node.

```shell
# upload rpm cache to meta controller
upload:
	ssh -t meta "sudo rm -rf /tmp/pkg.tgz"
	scp -r files/pkg.tgz meta:/tmp/pkg.tgz
	ssh -t meta "sudo mkdir -p /www/pigsty/; sudo rm -rf /www/pigsty/*; sudo tar -xf /tmp/pkg.tgz --strip-component=1 -C /www/pigsty/"
```

### Make offline pkg

When using the Pigsty sandbox, you can make an offline pkg from the cache of meta nodes in the sandbox by `make cache` and copying it locally.

```bash
# cache rpm packages from meta controller
cache:
	rm -rf pkg/* && mkdir -p pkg;
	ssh -t meta "sudo tar -zcf /tmp/pkg.tgz -C /www pigsty; sudo chmod a+r /tmp/pkg.tgz"
	scp -r meta:/tmp/pkg.tgz files/pkg.tgz
	ssh -t meta "sudo rm -rf /tmp/pkg.tgz"
```



## Prepare pkg.tgz for Production

Before using an offline pkg in a production environment, you must ensure that the OS of the production environment is the same as the **OS** on which the **offline pkg** was made. Pigsty uses CentOS 7.8 by default.

If you need to run Pigsty on other versions of OS (e.g., CentOS 7.3, 7.7), it is recommended that you perform the initialization process thoroughly in a sandbox with the same version of the operating system installed, **without using the offline pkg** and by downloading directly from the upstream repo.

After the regular initialization is completed, users can make the software cache for a specific OS as an offline package by `make cache` or manually executing the relevant commands.

To build an offline installer package from a local meta node that has completed initialization.

```bash
tar -zcf /tmp/pkg.tgz -C /www pigsty # Make an offline package
```

Using an offline pkg in a production environment is similar to a sandbox.  You need to copy `pkg.tgz` to the meta node and then unzip the offline pkg to the target address.

Here, take the default `/www/pigsty` as an example. To extract all the contents of the zip package (RPM package, repo_complete markup file, meta DB of repodata source, etc.) to the target dir `/www/pigsty`, you can use the following command.

```bash
mkdir -p /www/pigsty/
sudo rm -rf /www/pigsty/*
sudo tar -xf /tmp/pkg.tgz --strip-component=1 -C /www/pigsty/
```

