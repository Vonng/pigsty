# gitea

Schema Migrator for PostgreSQL

```bash
cd app/gitea; docker-compose up -d
```

Visit [http://ddl.pigsty](http://ddl.pigsty) or http://10.10.10.10:8887


```bash
make up      # pull up gitea with docker-compose in minimal mode
make run     # launch gitea with docker , local data dir and external PostgreSQL
make view    # print gitea access point
make log     # tail -f gitea logs
make info    # introspect gitea with jq
make stop    # stop gitea container
make clean   # remove gitea container
make pull    # pull latest gitea image
make rmi     # remove gitea image
make save    # save gitea image to /tmp/gitea.tgz
make load    # load gitea image from /tmp
```



## Use External PostgreSQL

gitea use its internal sqlite database by default, You can use external PostgreSQL for higher durability.

```yaml
# postgres://dbuser_gitea:DBUser.gitea@10.10.10.10:5432/gitea
db:   { name: gitea, owner: dbuser_gitea, comment: gitea primary database }
user: { name: dbuser_gitea , password: DBUser.gitea, roles: [ dbrole_admin ] }
```

