# PostgresML

[PostgresML](https://postgresml.org/) is an PostgreSQL extension with the support for latest LLMs, vector operations, classical Machine Learning and good old Postgres application workloads.

PostgresML (pgml) is a PostgreSQL extension written in Rust. You can run standalone docker images, but this is not a docker-compose template introduction, this file is for documentation purpose only.

PostgresML is officially supported on Ubuntu 22.04, but we also maintain an RPM version for EL 8/9, if you don't need CUDA & NVIDIA stuff. 

You'll need the Internet access on the database nodes to download python dependencies from PyPI and models from HuggingFace.



-----------------------

## Configuration

PostgresML is a RUST extension with official Ubuntu support. Pigsty maintains an RPM version for PostgresML on EL8 and EL9.


**Launch new Cluster**

PostgresML  2.7.9 is available for PostgreSQL 15 on Ubuntu 22.04 (Official), Debian 12 and EL 8/9 (Pigsty). To enable `pgml`, you have to install the extension first:  

```yaml
pg-meta:
  hosts: { 10.10.10.10: { pg_seq: 1, pg_role: primary } }
  vars:
    pg_cluster: pg-meta
    pg_users:
      - {name: dbuser_meta     ,password: DBUser.Meta     ,pgbouncer: true ,roles: [dbrole_admin]    ,comment: pigsty admin user }
      - {name: dbuser_view     ,password: DBUser.Viewer   ,pgbouncer: true ,roles: [dbrole_readonly] ,comment: read-only viewer for meta database }
    pg_databases:
      - { name: meta ,baseline: cmdb.sql ,comment: pigsty meta database ,schemas: [pigsty] ,extensions: [{name: postgis, schema: public}, {name: timescaledb}]}
    pg_hba_rules:
      - {user: dbuser_view , db: all ,addr: infra ,auth: pwd ,title: 'allow grafana dashboard access cmdb from infra nodes'}
    pg_libs: 'pgml, pg_stat_statements, auto_explain'
    pg_extensions: [ 'pgml_15 pgvector_15 wal2json_15 repack_15' ]  # ubuntu
    #pg_extensions: [ 'postgresql-pgml-15 postgresql-15-pgvector postgresql-15-wal2json postgresql-15-repack' ]  # ubuntu
```

In EL 8/9, the extension name is `pgml_15`, corresponding name in ubuntu/debian is `postgresql-pgml-15`. and add `pgml` to `pg_libs`.


**Enable on Existing Cluster**

To enable `pgml` on existing cluster, install with ansible `package` module:

```bash
ansible pg-meta -m package -b -a 'name=pgml_15'
# ansible el8,el9 -m package -b -a 'name=pgml_15'           # EL 8/9
# ansible u22 -m package -b -a 'name=postgresql-pgml-15'    # Ubuntu 22.04 jammy
```



-----------------------

## Python Dependencies

You also have to install python dependencies for PostgresML on cluster nodes. Official tutorial: [installation](https://postgresml.org/docs/guides/developer-docs/installation)



**Install Python & PIP**

Make sure `python3`, `pip` and `venv` is installed:

```bash
# ubuntu 22.04 (python3.10), you have to install pip & venv with apt
sudo apt install -y python3 python3-pip python3-venv   
```

For EL 8 / EL9 and compatible distros, you can use python3.11 

```bash
# el 8/9, you can upgrade default pip & virtualenv if applicable
sudo yum install -y python3.11 python3.11-pip       # install latest python3.11
python3.11 -m pip install --upgrade pip virtualenv  # use python3.11 on el8 / el9
```

<details><summary>Using pypi mirrors</summary>

For mainland China user, consider using the tsinghua pypi [mirror](https://mirrors.tuna.tsinghua.edu.cn/help/pypi/).

```bash
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple    # setup global mirror (recommended)
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple some-package        # one-time install
```

</details>



**Install Requirements**

Create a python virtualenv and install requirements from [`requirements.txt`](https://github.com/postgresml/postgresml/blob/master/pgml-extension/requirements.txt) and [`requirements-xformers.txt`](https://github.com/postgresml/postgresml/blob/master/pgml-extension/requirements-xformers.txt) with `pip`.

> If you are using EL 8/9, you have to replace the `python3` with `python3.11` in the following commands.

```bash
su - postgres;                          # create venv with dbsu
mkdir -p /data/pgml; cd /data/pgml;     # make a venv directory
python3    -m venv /data/pgml           # create virtualenv dir (ubuntu 22.04)
source /data/pgml/bin/activate          # activate virtual env

# write down python dependencies and install with pip
cat > /data/pgml/requirments.txt <<EOF
accelerate==0.22.0
auto-gptq==0.4.2
bitsandbytes==0.41.1
catboost==1.2
ctransformers==0.2.27
datasets==2.14.5
deepspeed==0.10.3
huggingface-hub==0.17.1
InstructorEmbedding==1.0.1
lightgbm==4.1.0
orjson==3.9.7
pandas==2.1.0
rich==13.5.2
rouge==1.0.1
sacrebleu==2.3.1
sacremoses==0.0.53
scikit-learn==1.3.0
sentencepiece==0.1.99
sentence-transformers==2.2.2
tokenizers==0.13.3
torch==2.0.1
torchaudio==2.0.2
torchvision==0.15.2
tqdm==4.66.1
transformers==4.33.1
xgboost==2.0.0
langchain==0.0.287
einops==0.6.1
pynvml==11.5.0
EOF

# install requirements with pip inside virtualenv
python3 -m pip install -r /data/pgml/requirments.txt
python3 -m pip install xformers==0.0.21 --no-dependencies

# besides, 3 python packages need to be installed globally with sudo!
sudo python3 -m pip install xgboost lightgbm scikit-learn
```





-----------------------

## Enable PostgresML

After installing the `pgml` extension and python dependencies on all cluster nodes, you can enable `pgml` on the PostgreSQL cluster.

[Configure](https://pigsty.io/docs/pgsql/admin/#config-cluster) cluster with `patronictl` command and add `pgml` to `shared_preload_libraries`, and specify your `venv` dir in `pgml.venv`:

```yaml
shared_preload_libraries: pgml, timescaledb, pg_stat_statements, auto_explain
pgml.venv: '/data/pgml'
```

After that, restart database cluster, and create extension with SQL command:

```sql
CREATE EXTENSION vector;        -- nice to have pgvector installed too!
CREATE EXTENSION pgml;          -- create PostgresML in current database
SELECT pgml.version();          -- print PostgresML version string
```

If it works, you should see something like:

```bash
# create extension pgml;
INFO:  Python version: 3.11.2 (main, Oct  5 2023, 16:06:03) [GCC 8.5.0 20210514 (Red Hat 8.5.0-18)]
INFO:  Scikit-learn 1.3.0, XGBoost 2.0.0, LightGBM 4.1.0, NumPy 1.26.1
CREATE EXTENSION

# SELECT pgml.version(); -- print PostgresML version string
 version
---------
 2.7.8
```

You are all set! Check PostgresML for more details: https://postgresml.org/docs/guides/use-cases/
