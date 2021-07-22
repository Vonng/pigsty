#!/usr/bin/env python3
# -*- coding: utf-8 -*- #
__author__ = 'Vonng (rh@vonng.com)'

import os, sys, json, yaml
from psql import *
from argparse import ArgumentParser


def usage():
    print("""bin/load_cls.py <-p cls_path> [-d <pgurl>] """)
    exit(1)


###########################
# parse arguments
###########################
DEFAULT_PGURL = ''
if 'METADB_URL' in os.environ:
    DEFAULT_PGURL = os.environ['METADB_URL']

parser = ArgumentParser(description="load config arguments")
parser.add_argument('-p', "--path", required=True, help="cls definition path")
parser.add_argument('-d', "--data", default=DEFAULT_PGURL, help="postgres cmdb pgurl, ${METADB_URL} by default")

args = parser.parse_args()


###########################
# precheck conf
###########################
def get_conf(path):
    return json.loads(json.dumps(yaml.safe_load(open(path, 'r'))))


def check_cluster(cls_define):
    if 'hosts' not in cls_define:
        raise ValueError('invalid cluster config: hosts not in top level object')
    if 'vars' not in cls_define:
        raise ValueError('invalid cluster config: vars not in top level object')

    vars = cls_define["vars"]
    if 'pg_cluster' not in vars:
        raise ValueError('invalid cluster config: pg_cluster not in top level object')
    cls = vars["pg_cluster"]

    has_primary = False
    ipset = set()
    for ip, ins_define in cls_define["hosts"].items():
        if ip in ipset:
            raise ValueError('duplicate ip address found')
        ipset.add(ip)
        if 'pg_seq' not in ins_define:
            raise ValueError('invalid instance config: pg_seq not allocated')
        if 'pg_role' not in ins_define:
            raise ValueError('invalid instance config: pg_role not allocated')
        pg_role = ins_define["pg_role"]
        if pg_role not in ["primary", "replica", "offline", "standby", "delayed"]:
            raise ValueError('invalid instance config: invalid pg_role %s' % pg_role)
        if pg_role == "primary" and has_primary:
            raise ValueError("invalid cluster config: multiple primary detected!")

    return cls


def check_clusters(conf):
    cls_set = set()
    for cls, cls_define in conf.items():
        if cls in cls_set:
            raise ValueError("duplicate cluster found %s" % cls)
        cls_set.add(cls)
        pg_cluster = check_cluster(cls_define)
        if cls != pg_cluster:
            raise ValueError("cls group name %s not equal to pg_cluster %s" % (cls, pg_cluster))
    return


###########################
# load config
###########################
print("load cluster definition from %s to %s" % (args.path, args.data))
conf = get_conf(args.path)
check_clusters(conf)
print("=[cluster]==========")
for k, v in conf.items():
    print(k)

###########################
# write into cmdb
###########################
print("=[results]==========")
psql = PSQL(args.data)
psql.execute('SELECT pigsty.upsert_clusters(%s);', (Json(conf),))

###########################
# list results
###########################
for cls, hosts in psql.ifetch("""select cls, hosts from pigsty.cluster_config;"""):
    print("%-32s\t%s" % (cls, list(hosts.keys())))
