# PostgresML

[PostgresML](https://postgresml.org/) is an PostgreSQL extension with the support for latest LLMs, vector operations, classical Machine Learning and good old Postgres application workloads.

This is not a docker-compose application, but a RUST extension for PostgreSQL, And this file is for documentation purpose only.

-----------------------

## Configuration

PostgresML is a RUST extension, and pre-packed by Pigsty. But it require extra dependencies to run. (available on EL7/EL8, PG15 only)

Check the official [tutorial](https://postgresml.org/docs/guides/setup/v2/installation.) before launching: https://postgresml.org/docs/guides/setup/v2/installation.

To setup a PostgresML cluster, you database should have the Internet access, and access to hugging face.

```bash
# install postgresml, python3.11 and 3.11 pip
sudo yum install -y postgresml_15
sudo yum install -y python3.11 python3.11-pip
sudo python3.11 -m pip install xgboost lightgbm
```

Setup python environment for PostgresML, and install dependencies.

```bash
su - postgres;
mkdir -p /data/pgml; cd /data/pgml;

cat > requirements.txt <<EOF
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

cat > requirements-xformers.txt <<EOF
xformers==0.0.21
EOF

# create python3.11 venv
python3.11 -m pip install virtualenv    # install virtualenv
python3.11 -m venv venv                 # create a virtual environment named venv
source /data/pgml/venv/bin/activate     # activate that venv

# install other dependencies with pip
pip install -r requirements.txt
pip install -r requirements-xformers.txt --no-dependencies


```

For mainland China user, consider using the tsinghua pypi [mirror](https://mirrors.tuna.tsinghua.edu.cn/help/pypi/).

```bash
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple some-package        # one-time install
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple    # setup global mirror
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
Time: 1650.319 ms (00:01.650)
postgres@meta-1:5432/meta=# SELECT pgml.version();          -- print PostgresML version string
 version
---------
 2.7.8
(1 row)

```

You are all set!
