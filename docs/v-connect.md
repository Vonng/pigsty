# Connect

## Overview

|                            Name                             |    Type    | Level  | Description |
| :----------------------------------------------------------: | :--------: | :---: | ---- |
|              [proxy_env](#proxy_env)               |  `dict`  |   G   | proxy environment variables |

## Tricks

When using Ansible to execute a script on a remote machine, the default requires that the remote machine has direct access to log in via ssh and that the user logging in has password-free sudo privileges.

If you are unable to perform SSH login using **password-free**, you can manually enter the SSH password by adding the `--ask-pass` or `-k` parameter when executing the script.

If you are unable to execute remote sudo commands using **password-free**, you can add the `--ask-become-pass` or `-K` parameter when executing the script and enter the sudo password manually.

If the administrative account does not exist on the target machine, you can create it using another user with remote login administrator status, using `node_admin` in the `pgsql.yml` script.

For example：

```bash
./pgsql --limit <target_hosts>  --tags node_admin  -e ansible_user=<another_admin> --ask-pass --ask-become-pass 
```



## Details

### proxy_env

In some areas where there is an "Internet GFW", some software downloads may be affected.

For example, when accessing the official PostgreSQL source from mainland China,
the download speed may only be a few kilobytes per second. 
However, if a proper HTTP proxy is used, it can reach several MB per second. 
Therefore, if the user has a proxy server, please configure it via [`proxy_env`](#proxy_env), as in the following example.


```yaml
proxy_env: # global proxy env when downloading packages
  http_proxy: 'http://username:password@proxy.address.com'
  https_proxy: 'http://username:password@proxy.address.com'
  all_proxy: 'http://username:password@proxy.address.com'
  no_proxy: "localhost,127.0.0.1,10.0.0.0/8,192.168.0.0/16,*.pigsty,*.aliyun.com,mirrors.aliyuncs.com,mirrors.tuna.tsinghua.edu.cn,mirrors.zju.edu.cn"
```



### ansible_host

If the user's environment uses a springboard machine,
or has some customization that prevents access via the simple `ssh <ip>` method;
then consider using Ansible's connection parameters. `ansible_host` is the most typical of ansible connection parameters.

> [Ansible SSH Parameters](https://docs.ansible.com/ansible/2.3/intro_inventory.html#list-of-behavioral-inventory-parameters)
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

The simplest usage is to configure `ssh alias` to `ansible_host`, and `ansible_host` to `<name>` as long as the user can access the target machine by means of `ssh <name>`.

Note that these variables are **instance level** variables.



## Caveat

Note that the default configuration for the sandbox environment uses **SSH alias** as the connection parameter, this is because the vagrant host uses the SSH alias configuration when accessing the virtual machine. Production environments are recommended to use IP connections directly.

```yaml
pg-meta:
  hosts:
    10.10.10.10: {pg_seq: 1, pg_role: primary, ansible_host: meta}
```

