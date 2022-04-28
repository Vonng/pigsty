# Jupyter Lab

## TL;DR

```bash
./infra-jupyter.yml # install jupyter on meta node on port 8888 with user jupyter and password pigsty
./infra-jupyter.yml -e jupyter_port=8887 # use another port 8887 by default
./infra-jupyter.yml -e jupyter_username=osuser_jupyter jupyter_password=pigsty2 # use another password
```


## Jupyter Config

| ID  | Name                                    |           Section           | Type | Level | Comment                       |
|-----|-----------------------------------------|-----------------------------|------|-------|-------------------------------|
| 220 | [`jupyter_port`](#jupyter_port)         | [`JUPYTER`](#JUPYTER)       | int  | G     | jupyter server listen port |
| 221 | [`jupyter_username`](#jupyter_username) | [`JUPYTER`](#JUPYTER)       | bool | G     | os user for jupyter lab       |
| 222 | [`jupyter_password`](#jupyter_password) | [`JUPYTER`](#JUPYTER)       | bool | G     | password for jupyter lab      |


Jupyter Lab is a complete data science R&D env based on IPython Notebook for data analysis and visualization. It is currently an optional Beta feature and is only enabled in the demo by default.

Because JupyterLab provides a Web Terminal feature, it is not recommended to enable it in production env, you can use [`infra-jupyter`](p-infra.md#infra-jupyter) to deploy it manually on the meta node.


### Default Values

```yaml
jupyter_username: jupyter       # os user name, special names: default|root (dangerous!)
jupyter_password: pigsty        # default password for jupyter lab (important!)
jupyter_port: 8887              # default port for jupyter lab
```


### `jupyter_port`

Which port will jupyter lab server listen on? 8888 by default


### `jupyter_username`

OS user used by Jupyter, type: `bool`, level: G, default value: `"jupyter"`.

The same goes for other usernames, but the special username `default` will run Jupyter Lab with the user who is currently running the installation (usually administrator), which is more convenient, but also more dangerous.



### `jupyter_password`

Password for Jupyter Lab, type: `bool`, level: G, default value: `"pigsty"`.

If Jupyter is enabled, it is highly recommended to change this password. Salted and obfuscated passwords are written to `~jupyter/.jupyter/jupyter_server_config.json` by default.



## Jupyter Playbook

### `infra-jupyter`

Playbook [`infra-jupyter.yml`](https://github.com/Vonng/pigsty/blob/master/infra-jupyter.yml) will install JupyterLab on the meta node.

It's a handy data analysis IDE for python. It's also risky because of its web shell functionality. So it's disabled by default. And enabled only in the Demo environment.

Refer to [Config: Jupyter](#JUPYTER-Config) for configuring Jupiter, then just execute this playbook.

