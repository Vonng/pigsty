# PostgresML

[PostgresML](https://postgresml.org/) is an PostgreSQL extension with the support for latest LLMs, vector operations, classical Machine Learning and good old Postgres application workloads.

This is not a docker-compose application, but a RUST extension for PostgreSQL, And this file is for documentation purpose only.

-----------------------

## Configuration

PostgresML is a RUST extension, and pre-packed by Pigsty. But it require extra dependencies to run. (only available on EL8/EL9 and PG15)

Check the official [tutorial](https://postgresml.org/docs/guides/setup/v2/installation.) before launching: https://postgresml.org/docs/guides/setup/v2/installation.

To setup a PostgresML cluster, your node should have access to the Internet: PYPI & HuggingFace.

```bash
sudo yum install -y postgresml_15                # install the extension rpm
sudo yum install -y python3.11 python3.11-pip    # install python3.11 and pip
sudo python3.11 -m pip install --upgrade pip     # upgrade pip and install requirements
sudo python3.11 -m pip install virtualenv       # install virtualenv
sudo python3.11 -m pip install -r ~/pigsty/app/pgml/requirements.txt
sudo python3.11 -m pip install -r ~/pigsty/app/pgml/requirements-xformers.txt --no-dependencies
```

<details><summary>Using pypi mirrors</summary>

For mainland China user, consider using the tsinghua pypi [mirror](https://mirrors.tuna.tsinghua.edu.cn/help/pypi/).

```bash
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple some-package        # one-time install
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple    # setup global mirror
```

</details>


Setup python virtual environment for PostgresML

```bash
su - postgres;  # create venv with dbsu
mkdir -p /data/pgml; cd /data/pgml;
python3.11 -m venv /data/pgml/venv      # create a virtual environment named venv
source /data/pgml/venv/bin/activate     # activate that virtual env

# install other dependencies with pip
pip install -r requirements.txt
pip install -r requirements-xformers.txt --no-dependencies
```

To create extension on existing cluster, you have to configure the following parameters with `patronictl edit-config`

```yaml
shared_preload_libraries: pgml, timescaledb, pg_stat_statements, auto_explain
pgml.venv: '/data/pgml/venv'
```

After that, restart database cluster, and try:

```sql
-- CREATE EXTENSION vector;     # nice to have vector installed!
CREATE EXTENSION pgml;          -- create PostgresML in current database
SELECT pgml.version();          -- print PostgresML version string
```

If it works, you should see something like:

```
postgres@meta-1:5432/meta=# create extension pgml;
INFO:  Python version: 3.11.2 (main, May 24 2023, 00:00:00) [GCC 11.3.1 20221121 (Red Hat 11.3.1-4)]
INFO:  Scikit-learn 1.3.0, XGBoost 2.0.0, LightGBM 4.1.0, NumPy 1.26.0
CREATE EXTENSION

postgres@meta-1:5432/meta=# SELECT pgml.version(); -- print PostgresML version string
 version
---------
 2.7.8
(1 row)
```

You are all set! Check PostgresML for more details: https://postgresml.org/docs/guides/predictions/overview
