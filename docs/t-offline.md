# Offline Installation

To ensure system stability, Pigsty downloads all dependent packages from the Internet and creates [local yum repo](v-repo.md) on meta node during installation.

The total size of all packages is about 1GB, and the download speed depends on the user's network condition. 

Although Pigsty has tried to use mirror sources as much as possible to speed up the download, 
a small portion of packages may still be blocked by firewalls and may appear very slow (especially in Mainland China).
Users can set up a download proxy via the [**`proxy_env`**](v-connect.md#proxy_env) to resolve this.

If you are using a different OS than CentOS 7.8, 
it is usually recommended performing an online installation procedure instead of using `pkg.tgz` directly.
Cause the `pkg.tgz` are made under CentOS 7.8, some rpms **MAY** be incompatible for other OS version.  



and cache the downloaded software after the first initialization is complete, see [**Making an offline installer**](#Making an offline installer).

If you wish to skip the long download process, or if the execution control meta-node **does not have Internet access**, consider downloading a pre-packaged **offline installer**.



## Contents of the offline installation package

To **quickly** pull up Pigsty, it is **recommended** to use the offline download package and upload method to complete the installation.

The offline installer includes all packages from the local Yum repository. By default, Pigsty is installed at [Infra Init](p-infra/) when the local Yum repository is created.

```
{{ repo_home }}
  |---- {{ repo_name }}.repo
  ^---- {{ repo_name}}/repo_complete
  ^---- {{ repo_name}}/**************.rpm
```

By default, `{{ repo_home }}` is the root directory of the Nginx static file server, which defaults to `/www`, and `repo_name` is a custom local source name, which defaults to `pigsty`.

By default, the `/www/pigsty` directory contains all RPM packages, and the offline installer is actually a zip archive of the `/www/pigsty` directory.

The principle of the offline installation package is that Pigsty [checks](https://github.com/Vonng/pigsty/blob/master/roles/repo/tasks/main.yml#L49) if the local Yum source-related files already exist during the execution of the infrastructure initialization. If they already exist, the process of downloading the package and its dependencies is skipped.

The marker file used for the check is `{{ repo_home }}/{{ repo_name }}/repo_complete`, by default `/www/pigsty/repo_complete`, if this marker file exists, (usually set by Pigsty after the local source is created), then the local source has created and can be used directly. Otherwise, Pigsty will perform the usual download logic. Once the download is complete, you can archive a compressed copy of the directory, which can be used to speed up the initialization of other environments.



## Sandbox environment

### Downloading offline installers

Pigsty comes with a sandbox environment. The offline installer for the sandbox environment is placed in the [`files`](https://github.com/Vonng/pigsty/tree/master/files) directory by default, and can be downloaded from [Github Release](https://github. com/Vonng/pigsty/releases) page.

```bash
curl -SL https://github.com/Vonng/pigsty/releases/download/${VERSION}/pkg.tgz -o dist/${VERSION}/pkg.tgz
```

Pigsty's official CDN also provides the latest version of ``pkg.tgz`` for download, just execute the following command.

```bash
make downlaod
curl http://pigsty-1304147732.cos.accelerate.myqcloud.com/pkg.tgz -o files/pkg.tgz
```

### Upload offline installer

When using the Pigsty sandbox, after downloading the offline installation to the local `files` directory, you can directly upload the offline installation to the **meta node** using the shortcut command `make copy-pkg` provided by Makefile.

Using ``make upload`` will also copy the local offline installer (Yum cache) to the meta node.

``shell
# upload rpm cache to meta controller
upload:
ssh -t meta "sudo rm -rf /tmp/pkg.tgz"
scp -r files/pkg.tgz meta:/tmp/pkg.tgz
ssh -t meta "sudo mkdir -p /www/pigsty/; sudo rm -rf /www/pigsty/*; sudo tar -xf /tmp/pkg.tgz --strip-component=1 -C /www/pigsty/"
```

### Making an offline installer

When using the Pigsty sandbox, you can make an offline installer from the cache of meta nodes in the sandbox by ``make cache`` and copy it locally.

```bash
# cache rpm packages from meta controller
cache:
	rm -rf pkg/* && mkdir -p pkg;
	ssh -t meta "sudo tar -zcf /tmp/pkg.tgz -C /www pigsty; sudo chmod a+r /tmp/pkg.tgz"
	scp -r meta:/tmp/pkg.tgz files/pkg.tgz
	ssh -t meta "sudo rm -rf /tmp/pkg.tgz"
```



## Installing packages offline in production environment

Before using an offline installer in a production environment, you must ensure that the operating system of the production environment is the same as the operating system of the machine **which made the **offline installer**. The offline installer provided by Pigsty uses CentOS 7.8 by default.

Using a different OS version of the offline installer **may** or may not cause errors, and we strongly advise against this.

If you need to run Pigsty on another version of operating system (e.g. CentOS 7.3, 7.7, etc.), it is recommended that users perform the initialization process completely in a sandbox with the same version of the operating system installed, **not using the offline installer**, but by downloading directly from the upstream source. For production environment meta-nodes without network access, it is critical to produce offline packages.

After the regular initialization is complete, users can hit the software cache for a specific operating system as an offline installation package by `make cache` or manually executing the relevant command. for use in production environments.

To build an offline installer from a local metanode where initialization is complete.

```bash
tar -zcf /tmp/pkg.tgz -C /www pigsty # Make an offline package
```

Using an offline installer in a production environment is similar to a sandbox environment in that the user needs to copy `pkg.tgz` to the meta node and then unzip the offline installer to the target address.

Here, take the default `/www/pigsty` as an example, to extract all the contents of the zip package (RPM package, repo_complete markup file, metadatabase of repodata source, etc.) to the target directory `/www/pigsty`, you can use the following command.

```bash
mkdir -p /www/pigsty/
sudo rm -rf /www/pigsty/*
sudo tar -xf /tmp/pkg.tgz --strip-component=1 -C /www/pigsty/
```

