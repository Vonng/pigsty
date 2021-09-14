# 连接参数

## 参数概览

|          名称           |  类型  | 层级 | 说明           |
| :---------------------: | :----: | :--: | -------------- |
| [proxy_env](#proxy_env) | `dict` |  G   | 代理服务器配置 |


## 连接技巧

使用Ansible在远程机器上执行剧本时，默认需要远程机器上可以直接通过ssh登陆，且登陆的用户具有免密码sudo的权限。

如果您无法使用**免密码**的方式执行SSH登陆，可以在执行剧本时添加`--ask-pass`或`-k`参数，手工输入SSH密码。

如果您无法使用**免密码**的方式执行远程sudo命令，可以在执行剧本时添加`--ask-become-pass`或`-K`参数，手工输入sudo密码。

如果管理账号在目标机器上不存在，您可以使用其他具有远程登录管理员身份的用户，使用 `pgsql.yml` 剧本中的 `node_admin` 进行创建。

例如：

```bash
./pgsql --limit <target_hosts>  --tags node_admin  -e ansible_user=<another_admin> --ask-pass --ask-become-pass 
```

详情请参考：[准备：管理用户置备](t-prepare.md#管理用户置备)


## 参数详解

### proxy_env

在某些受到“互联网封锁”的地区，有些软件的下载会受到影响。

例如，从中国大陆访问PostgreSQL的官方源，下载速度可能只有几KB每秒。但如果使用了合适的HTTP代理，则可以达到几MB每秒。因此如果用户有代理服务器，请通过`proxy_env`进行配置，样例如下：

```yaml
proxy_env: # global proxy env when downloading packages
  http_proxy: 'http://username:password@proxy.address.com'
  https_proxy: 'http://username:password@proxy.address.com'
  all_proxy: 'http://username:password@proxy.address.com'
  no_proxy: "localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,*.pigsty,*.aliyun.com,mirrors.aliyuncs.com,mirrors.tuna.tsinghua.edu.cn,mirrors.zju.edu.cn"
```



### ansible_host

如果用户的环境使用了跳板机，或者进行了某些定制化修改，无法通过简单的`ssh <ip>`方式访问，那么可以考虑使用Ansible的连接参数。`ansible_host`是ansiblel连接参数中最典型的一个。

> [Ansible中关于SSH连接的参数](https://docs.ansible.com/ansible/2.3/intro_inventory.html#list-of-behavioral-inventory-parameters)
>
> - ansible_host
>
>   The name of the host to connect to, if different from the alias you wish to give to it.
>
> - ansible_port
>
>   The ssh port number, if not 22
>
> - ansible_user
>
>   The default ssh user name to use.
>
> - ansible_ssh_pass
>
>   The ssh password to use (never store this variable in plain text; always use a vault. See [Variables and Vaults](https://docs.ansible.com/ansible/2.3/playbooks_best_practices.html#best-practices-for-variables-and-vaults))
>
> - ansible_ssh_private_key_file
>
>   Private key file used by ssh. Useful if using multiple keys and you don’t want to use SSH agent.
>
> - ansible_ssh_common_args
>
>   This setting is always appended to the default command line for **sftp**, **scp**, and **ssh**. Useful to configure a `ProxyCommand` for a certain host (or group).
>
> - ansible_sftp_extra_args
>
>   This setting is always appended to the default **sftp** command line.
>
> - ansible_scp_extra_args
>
>   This setting is always appended to the default **scp** command line.
>
> - ansible_ssh_extra_args
>
>   This setting is always appended to the default **ssh** command line.
>
> - ansible_ssh_pipelining
>
>   Determines whether or not to use SSH pipelining. This can override the `pipelining` setting in `ansible.cfg`.

最简单的用法是将`ssh alias`配置为`ansible_host`，只要用户可以通过 `ssh <name>`的方式访问目标机器，那么将`ansible_host`配置为`<name>`即可。

注意这些变量都是**实例级别**的变量。



## Caveat

请注意，沙箱环境的默认配置使用了 **SSH 别名** 作为连接参数，这是因为vagrant宿主机访问虚拟机时使用了SSH别名配置。生产环境建议直接使用IP连接。

```yaml
pg-meta:
  hosts:
    10.10.10.10: {pg_seq: 1, pg_role: primary, ansible_host: meta}
```

