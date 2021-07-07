# MetaDB

Load Pigsty Config into local PostgreSQL database.

You can install this app via

```bash
make   # load ~/pigsty/pigsty.yml to local meta db
```


Or have more control on source and destination

```
bin/load  </path/to/pigsty/config>  </url/of/target/postgres>
```


for example:

```bash
bin/load  ~/pigsty/pigsty.yml   service=meta
```