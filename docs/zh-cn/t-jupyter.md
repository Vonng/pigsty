# Jupyter Lab 使用说明

Jupyter Lab 是非常实用的Python数据分析环境。

默认情况下，Demo环境，单机配置模板中会启用 JupyterLab，生产环境部署模版中默认不会启用JupyterLab

## 启用Jupyter

要启用Jupyter Lab，用户需要设置 [`jupyter_enabled`](v-meta.md#jupyter_enabled) 参数为`true`。

那么Jupyter会使用[`jupyter_username`](v-meta.md#jupyter_username) 参数指定的用户运行本地Notebook服务器。

此外，需要配置[`node_meta_pip_install`](v-node.md#node_meta_pip_install) 参数，在元数据库初始化时正确通过pip安装。（默认值为 `'jupyterlab'`，无需修改）



## 访问Jupyter

Jupyter Lab可以从Pigsty首页导航进入，或通过默认域名 `lab.pigsty` 访问。

```yaml
# - reference - #
nginx_upstream:                               # domain names that will be used for accessing pigsty services
  - { name: jupyter,       domain: lab.pigsty,    endpoint: "127.0.0.1:8888" }     # jupyter lab (8888)
```

访问需要使用密码，由参数 [`jupyter_password`](v-meta.md#jupyter_password) 指定。

!> 如果您在生产环境中启用了Jupyter，请务必修改Jupyter的密码


