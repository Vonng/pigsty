# Covid Data Visualization

This is an example of store, load, visualize WHO COVID-19 dataset.

Usage: **Run this on meta node with admin user**


```bash
make ui          # install covid dashboards to grafana
make sql         # install covid database schema to metadb 
make download    # download history & latest csv data from WHO
make load        # load history & latest covid csv data into database 
```

Or just use `make all` to setup all stuff for you.

```bash
make all   # setup everything
```

If data already download (e.g get applications via downloading app.tgz), run `make all2` instead to skip download.


Demo: http://g.pigsty.cc/d/covid-overview



