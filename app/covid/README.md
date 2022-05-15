# Covid Data Visualization

This is an example of store, load, visualize WHO COVID-19 dataset.

Usage: **Run this on meta node with admin user**


## Install

```bash
make            # if local-data available
make all        # if local-data not available, download from internet
makd reload     # download and load latest data from WHO 
```

Subtasks:

```bash
make reload     # download latest data and pour it again
make ui         # install grafana dashboards
make sql        # install database schemas
make download   # download latest data
make load       # load downloaded data into database
make reload     # download latest data and pour it into database
```


## Dashboards

* [Covid Overview](http://demo.pigsty.cc/d/covid-overview)
* [Covid Country](http://demo.pigsty.cc/d/covid-country)
* [Covid Timeline](http://demo.pigsty.cc/d/covid-timeline-map?var-data_type=new_cases)


