# MINIO



## Parameters

There are 15 parameters about [`MINIO`](PARAM#MINIO) module.

| Parameter                                    | Type     | Level| Comment                                            |
| -------------------------------------------- |:--------:|:----:| -------------------------------------------------- |
| [`minio_user`](PARAM#minio_user)             | username | C    | minio os user, `minio` by default                   |
| [`minio_node`](PARAM#minio_node)             | string   | C    | minio node name pattern                                 |
| [`minio_data`](PARAM#minio_data)             | path     | C    | minio data dir(s), use {x...y} to specify multi drivers |
| [`minio_domain`](PARAM#minio_domain)         | string   | G    | minio external domain name, `sss.pigsty` by default     |
| [`minio_port`](PARAM#minio_port)             | port     | C    | minio service port, 9000 by default                     |
| [`minio_admin_port`](PARAM#minio_admin_port) | port     | C    | minio console port, 9001 by default                     |
| [`minio_access_key`](PARAM#minio_access_key) | username | C    | root access key, `minioadmin` by default                |
| [`minio_secret_key`](PARAM#minio_secret_key) | password | C    | root secret key, `minioadmin` by default                |
| [`minio_extra_vars`](PARAM#minio_extra_vars) | string   | C    | extra environment variables for minio server            |
| [`minio_alias`](PARAM#minio_alias)           | string   | G    | alias name for local minio deployment                   |
| [`minio_buckets`](PARAM#minio_buckets)       | bucket[] | C    | list of minio bucket to be created                      |
| [`minio_users`](PARAM#minio_users)           | user[]   | C    | list of minio user to be created                        |
