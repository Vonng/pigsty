# 部署教程：Jupyter Lab数据分析环境

## 太长不看

```bash
./infra-jupyter.yml # 在管理节点上安装 Jupyter Lab，使用8888端口，OS用户jupyter，默认密码 pigsty
./infra-jupyter.yml -e jupyter_port=8887 # 使用另一个端口（默认为8888）
./infra-jupyter.yml -e jupyter_username=osuser_jupyter jupyter_password=pigsty2 # 使用不同的操作系统用户与密码
```


## Jupyter配置

| ID  | Name                                    |           Section           | Type | Level | Comment                       |
|-----|-----------------------------------------|-----------------------------|------|-------|-------------------------------|
| 220  | [`jupyter_port`](v-infra.md#jupyter_enabled)              | [`JUPYTER`](v-infra.md#JUPYTER)                 | G     | 是否启用JupyterLab                   |
| 221  | [`jupyter_username`](v-infra.md#jupyter_username)            | [`JUPYTER`](v-infra.md#JUPYTER)                 | G     | Jupyter使用的操作系统用户            |
| 222  | [`jupyter_password`](v-infra.md#jupyter_password)            | [`JUPYTER`](v-infra.md#JUPYTER)                 | G     | Jupyter Lab的密码                    |


Jupyter Lab 是基于 IPython Notebook 的完整数据科学研发环境，可用于数据分析与可视化。默认安装，但不会启用Web Server。

因为JupyterLab提供了Web Terminal功能，因此不建议在生产环境中开启，可以使用 [`infra-jupyter`](p-infra.md#infra-jupyter) 在元节点上手动部署。


### 默认值 Values

```yaml
jupyter_username: jupyter       # os user name, special names: default|root (dangerous!)
jupyter_password: pigsty        # default password for jupyter lab (important!)
jupyter_port: 8887              # default port for jupyter lab
```


### `jupyter_port`

Jupyter监听端口, 类型：`int`，层级：G，默认值为：`8888`。



启用JupyterLab时，Pigsty会使用[`jupyter_username`](jupyter_username) 参数指定的用户运行本地Notebook服务器。
此外，需要确保配置[`node_meta_pip_install`](v-nodes.md#node_meta_pip_install) 参数包含默认值 `'jupyterlab'`。
Jupyter Lab可以从Pigsty首页导航进入，或通过默认域名 `lab.pigsty` 访问，默认监听于8888端口。


### `jupyter_username`

Jupyter使用的操作系统用户, 类型：`bool`，层级：G，默认值为：`"jupyter"`

其他用户名亦同理，但特殊用户名`default`会使用当前执行安装的用户（通常为管理员）运行 Jupyter Lab，这会更方便，但也更危险。



### `jupyter_password`

Jupyter Lab的密码, 类型：`bool`，层级：G，默认值为：`"pigsty"`

如果启用Jupyter，强烈建议修改此密码。加盐混淆的密码默认会写入`~jupyter/.jupyter/jupyter_server_config.json`。





## Jupyter剧本

### `infra-jupyter`

[`infra-jupyter.yml`](https://github.com/Vonng/pigsty/blob/master/infra-jupyter.yml) 剧本用于在元节点上加装 Jupyter Lab服务


Jupyter Lab 是非常实用的Python数据分析环境，但自带WebShell，风险较大。因此默认情况下，Demo环境，单机配置模板中会启用 JupyterLab，生产环境部署模版中默认不会启用JupyterLab

请参照：[配置:Jupyter](v-infra.md#JUPYTER) 中的说明调整配置清单，然后执行此剧本即可。

!> 如果您在生产环境中启用了Jupyter，请务必修改Jupyter的密码