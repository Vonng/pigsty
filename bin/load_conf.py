#!/usr/bin/env python3
# -*- coding: utf-8 -*- #
__author__ = 'Vonng (rh@vonng.com)'

from psql import *
from argparse import ArgumentParser
import os, json, yaml


def usage():
    print("""
    bin/load_conf [ -n | --name = pgsql ] 
                  [ -p | --path = ${PIGSTY_HOME}/pigsty.yml ]
                  [ -d | --data = ${METADB_URL} ] 
    Load config into cmdb pigsty schema     
    """)


###########################
# parse arguments
###########################
DEFAULT_PGURL = ''
DEFAULT_CONFIG_PATH = ''
PIGSTY_HOME = ''

if 'METADB_URL' in os.environ:
    DEFAULT_PGURL = os.environ['METADB_URL']
if 'PIGSTY_HOME' in os.environ:
    PIGSTY_HOME = os.environ['PIGSTY_HOME']
elif 'HOME' in os.environ:
    PIGSTY_HOME = os.path.join(os.environ['HOME'], 'pigsty')
if PIGSTY_HOME != '':
    DEFAULT_CONFIG_PATH = os.path.join(PIGSTY_HOME, 'pigsty.yml')

parser = ArgumentParser(description="load config arguments")
parser.add_argument('-n', "--name", default='pgsql', help="config profile name, pgsql by default")
parser.add_argument('-p', "--path", default=DEFAULT_CONFIG_PATH,
                    help="config path, ${PIGSTY_HOME}/pigsty.yml by default")
parser.add_argument('-d', "--data", default=DEFAULT_PGURL, help="postgres cmdb pgurl, ${METADB_URL} by default")

args = parser.parse_args()


###########################
# parse config
###########################
def get_config_json(path):
    return json.loads(json.dumps(yaml.safe_load(open(path, 'r'))))


def use_dynamic_inventory(ansible_cfg):
    if not os.path.exists(ansible_cfg):
        raise "%s not exists" % ansible_cfg
    cmd = """sed -ie 's/inventory.*/inventory = inventory.sh/g' %s""" % ansible_cfg
    if os.system(cmd) != 0:
        raise "fail to edit %s" % ansible_cfg
    os.remove(ansible_cfg + 'e')  # remove sed trash


def use_static_inventory(ansible_cfg):
    if not os.path.exists(ansible_cfg):
        raise "%s not exists" % ansible_cfg
    cmd = """sed -ie 's/inventory.*/inventory = pigsty.yml/g' %s""" % ansible_cfg
    if os.system(cmd) != 0:
        raise "fail to edit %s" % ansible_cfg
    os.remove(ansible_cfg + 'e')  # remove sed trash


def write_inventory_sh(path):
    with open(path) as dst:
        dst.write("#!/bin/bash\npsql service=meta -AXtwc 'SELECT text FROM pigsty.inventory;'")
    os.chmod(path, 0o755)


############################
# upsert config and activate
############################
print("load config %s from %s into %s" % (args.name, args.path, args.data))

conf = get_config_json(args.path)
psql = PSQL(args.data)
psql.execute('SELECT pigsty.upsert_config(%s, %s);', (Json(conf), args.name))
psql.execute('SELECT pigsty.activate_config(%s)', (args.name,))

print("\n=[Config]===============")
for name, is_active in psql.ifetch("""select name, is_active from pigsty.config;"""):
    print("%s %s" % (name, '*' if is_active else ''))

print("\n=[Cluster]===============")

for cls, hosts in psql.ifetch("""select cls, hosts from pigsty.cluster_config;"""):
    print("%-32s\t%s" % (cls, list(hosts.keys())))


