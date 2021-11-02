#!/usr/bin/env python3
# generate config template from pigsty.yml
import os, sys

script_path = sys.argv[0]
script_dir = os.path.dirname(script_path)
pigsty_yml = os.path.abspath(os.path.join(script_dir, '..', '..', 'pigsty.yml'))

print("load config from %s" % pigsty_yml)
raw_config = open(pigsty_yml, 'r').readlines()

# pigsty-demo.yml is exact same as pigsty.yml (default config for demo environment)
dst_path = os.path.join(script_dir, "pigsty-demo.yml")
print("generate %s" % dst_path)
with open(dst_path, 'w') as dst:
    for line in raw_config:
        dst.write(line)

# detect all.children
block_start, block_end = 9, -1
for i, line in enumerate(raw_config):
    if line.startswith('  vars:'):
        block_end = i
block_end -= 4

# and replace with less verbose version
production_config = """
all:  
  children:

    #----------------------------------#
    # meta nodes (admin controller)    #
    #----------------------------------#
    meta:
      vars: { meta_node: true , ansible_group_priority: 99 }
      hosts:
        10.10.10.10: { }


    #----------------------------------#
    # cluster: pg-meta (default cmdb)
    #----------------------------------#
    pg-meta:
      hosts:
        10.10.10.10: { pg_seq: 1, pg_role: primary , pg_offline_query: true }
      vars:
        pg_cluster: pg-meta
        pg_users:
          - { name: dbuser_meta , password: DBUser.Meta   , pgbouncer: true , roles: [ dbrole_admin ] , comment: pigsty admin user }
          - { name: dbuser_view , password: DBUser.Viewer , pgbouncer: true , roles: [ dbrole_readonly ] , comment: read-only viewer for meta database }
        pg_databases:
          - name: meta
            baseline: cmdb.sql
            comment: pigsty meta database
            connlimit: -1
            schemas: [ pigsty ]
            extensions:
              - { name: adminpack, schema: pg_catalog }
              - { name: postgis, schema: public }
              - { name: timescaledb }


    #----------------------------------#
    # cluster: pg-test (example cluster)
    #----------------------------------#
    #pg-test:
    #  hosts:
    #    10.10.10.11: { pg_seq: 1, pg_role: primary }
    #    10.10.10.12: { pg_seq: 2, pg_role: replica }
    #    10.10.10.13: { pg_seq: 3, pg_role: replica, pg_offline_query: true }
    #  vars:
    #    pg_cluster: pg-test
    #    pg_users: [ { name: test , password: test , pgbouncer: true , roles: [ dbrole_admin ] , comment: test user } ]
    #    pg_databases: [ { name: test , extensions: [ { name: postgis, schema: public } ] } ]



"""


# pigsty-tiny is variant of pigsty-demo
dst_path = os.path.join(script_dir, "pigsty-auto.yml")
print("generate %s" % dst_path)
with open(dst_path, 'w') as dst:
    skip_line = False
    for i, line in enumerate(raw_config):

        # skip next line with marks
        if skip_line > 0:
            skip_line -= 1
            continue

        # replace cluster definition
        if block_start <= i < block_end:
            continue
        elif i == block_end:
            dst.write(production_config)

        # rewrite config description
        elif line.startswith('# Desc'):  # overwrite config description
            dst.write('# Desc      :   Pigsty Auto-Generated Config Template\n')

        # reset dcs_exists_action = abort
        elif line.startswith('    dcs_exists_action:'):
            dst.write('    dcs_exists_action: abort                      # abort|skip|clean if dcs server already exists\n')

        # reset pg_exists_action = abort
        elif line.startswith('    pg_exists_action:'):
            dst.write('    pg_exists_action: abort                       # abort|skip|clean if postgres already exists\n')

        # reset node_dns_server = none
        elif line.startswith('    node_dns_server:'):
            dst.write('    node_dns_server: none                         # add (default) | none (skip) | overwrite (remove old settings)\n')

        # reset node_timezone = '' (do not change timezone)
        elif line.startswith('    node_timezone:'):
            dst.write("    node_timezone: ''                             # default node timezone, empty will not change. (e.g. Asia/Hong_Kong)\n")

        # reset node_ntp_config = false (do not change ntp server)
        elif line.startswith('    node_ntp_config:'):  # disable ntp config for production
            dst.write('    node_ntp_config: false                        # config ntp service? false will leave it with system default\n')

        # remove demo admin public keys
        elif line.startswith('    node_admin_pks:'):  # remove admin public key of demo user
            dst.write(line.replace('node_admin_pks:    ', 'node_admin_pks: [ ]'))
            skip_line = 1

        # skip dns records in nameserver
        elif line.startswith('    dns_records:'):  # overwrite config description
            dst.write('    dns_records: [ ]                              # dynamic dns record resolved by dnsmasq\n')
            skip_line = 10


        # comment vip settings
        elif line.startswith('        vip_'):  # reset vip config for production
            dst.write('        # ' + line.lstrip())

        # disable jupyter by default for production
        elif line.startswith('    jupyter_enabled'):
            dst.write('    jupyter_enabled: false                        # disable jupyter on production by default\n')

        # disable pgweb by default for production
        elif line.startswith('    pgweb_enabled'):
            dst.write('    pgweb_enabled: false                          # disable pgweb on production by default\n')

        # skip isd app entry for production
        elif line.startswith('      - { name: ISD'):
            continue

        # skip covid app entry for production
        elif line.startswith('      - { name: Covid'):
            continue

        # skip applog app entry for production
        elif line.startswith('      - { name: Applog'):
            continue

        # skip example sysctl param
        elif line.startswith('    # net.bridge.bridge-nf-call-iptables'):
            continue

        # skip grafana pg_url
        elif line.startswith('    # if postgres is used'):
            continue
        elif line.startswith('    grafana_pgurl:'):
            dst.write(line.replace('grafana_pgurl:', "grafana_pgurl: ''                             #"))


        # reset pg_dbsu_ssh_exchange = false
        elif line.startswith('    pg_dbsu_ssh_exchange'):
            dst.write("    pg_dbsu_ssh_exchange: false                   # exchange postgres dbsu ssh key among same cluster ?\n")

        # reset node_timezone = '' (do not change timezone)
        elif line.startswith('    pg_hostname: true'):
            dst.write("    pg_hostname: false                            # overwrite node hostname with pg instance name\n")

        # setup 1GiB dummy file size for production
        elif line.startswith('    pg_dummy_filesize'):
            dst.write('    pg_dummy_filesize: 1GiB                       # /pg/dummy hold some disk space for emergency use\n')


        else:
            dst.write(line)
