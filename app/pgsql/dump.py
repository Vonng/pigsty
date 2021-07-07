#!/usr/bin/env python3

import json, requests

# https://grafana.com/docs/grafana/latest/http_api/
GRAFANA_ENDPOINT = "http://g.pigsty"
GRAFANA_USERNAME = 'admin'
GRAFANA_PASSWORD = 'pigsty'

def fix_dashboard(dashboard):
    if "meta" in dashboard:
        # means it is dumped from grafana directly, take inner dashboard object
        dashboard = dashboard["dashboard"]

    # set id = null, so that
    if "id" in dashboard and dashboard["id"] is not None:
        dashboard["id"] = None

    # remove template current variable
    if "templating" in dashboard and "list" in dashboard["templating"]:
        i = 0
        for item in dashboard["templating"]["list"]:
            if "current" in item:
                dashboard["templating"]["list"][i]["current"] = {}
            i = i + 1
    return dashboard

def get_dashboard(uid):
    d = requests.get(
        "http://g.pigsty/api/dashboards/uid/%s" % uid,
        auth=requests.auth.HTTPBasicAuth('admin', 'pigsty'),
        headers={'Content-Type': 'application/json'}
    ).json()
    return fix_dashboard(d)

def list_dashboards():
    return requests.get(
        "http://g.pigsty/api/search",
        auth=requests.auth.HTTPBasicAuth('admin', 'pigsty'),
        headers={'Content-Type': 'application/json'}
    ).json()


uids = [i['uid'] for i in list_dashboards() if i['uid'].startswith('pgsql')]
defs = [ ('%s.json'%uid, get_dashboard(uid)) for uid in uids]

for name,d in defs:
    fp = 'dashboards/%s'%name
    print(fp)
    with open(fp,'w') as dst:
        json.dump(d, dst, indent=4)


