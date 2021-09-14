#!/usr/bin/env python3
# generate config template from pigsty.yml
import os, sys

script_path = sys.argv[0]
script_dir = os.path.dirname(script_path)
pigsty_yml = os.path.abspath(os.path.join(script_dir, '..', '..', 'pigsty.yml'))

print("load config from %s" % pigsty_yml)
raw_config = open(pigsty_yml, 'r').readlines()

# pigsty-demo4 is exact same as pigsty.yml
dst_path = os.path.join(script_dir, "pigsty-demo4.yml")
print("generate %s" % dst_path)
with open(dst_path, 'w') as dst:
    for line in raw_config:
        dst.write(line)

# pigsty-pg14 add pg14 support
dst_path = os.path.join(script_dir, "pigsty-pg14.yml")
print("generate %s" % dst_path)
pgdg14_repo = """
      - name: pgdg14-beta
        description: PostgreSQL 14 beta for RHEL/CentOS $releasever - $basearch
        enabled: yes
        gpgcheck: no
        baseurl:
          - https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/yum/testing/14/redhat/rhel-$releasever-$basearch # tuna
          - https://download.postgresql.org/pub/repos/yum/testing/14/redhat/rhel-$releasever-$basearch             # official
     
"""
with open(dst_path, 'w') as dst:
    for line in raw_config:
        if line.startswith('# Desc'):
            dst.write('# Desc      :   Pigsty 4-node-demo (PG14 version)\n')
            continue
        elif "pg_version:" in line:
            dst.write(line.replace('13', '14'))
            continue
        elif 'name: pgdg13' in line:
            dst.write(pgdg14_repo)
            dst.write(line)
        elif '        pg_cluster: pg-test' in line:
            dst.write(line)
            dst.write('        pg_extensions: [ ]                  # no extension available for pg14 now\n')
            dst.write('        pg_packages:                        # install pg14 packages instead of 13\n')
            dst.write(
                "          - %s\n" % 'postgresql14* pgbouncer patroni pg_exporter pgbadger patroni patroni-consul patroni-etcd pgbouncer pgbadger pg_activity')
            dst.write(
                "          - %s\n" % 'python3 python3-psycopg2 python36-requests python3-etcd python3-consul python36-urllib3 python36-idna python36-pyOpenSSL python36-cryptography')

        elif '      - postgresql13*          ' in line:
            dst.write(line.replace('postgresql13', 'postgresql14'))
        else:
            dst.write(line)

# detect pg-test range
block_start, block_end = 0, -1
for i, line in enumerate(raw_config):
    if line.startswith('    pg-test:'):
        block_start = i
    if line.startswith('  vars:'):
        block_end = i
block_start -= 6
block_end -= 4

# pigsty-demo is commented version of pigsty-demo4.yml
dst_path = os.path.join(script_dir, "pigsty-demo.yml")
print("generate %s" % dst_path)
with open(dst_path, 'w') as dst:
    for i, line in enumerate(raw_config):
        if block_start <= i < block_end:
            dst.write('#' + line)
            continue
        elif line.startswith('# Desc'):
            dst.write('# Desc      :   Pigsty 1-node demo (default config after sandbox configure)\n')
            continue
        else:
            dst.write(line)

# pigsty-tiny is variant of pigsty-demo
dst_path = os.path.join(script_dir, "pigsty-tiny.yml")
print("generate %s" % dst_path)
with open(dst_path, 'w') as dst:
    skip_line = False
    for i, line in enumerate(raw_config):
        if skip_line:
            skip_line = False
            continue
        if block_start <= i < block_end:
            continue
            # dst.write('#' + line)
        elif line.startswith('# Desc'):
            dst.write('# Desc      :   Pigsty 1-tiny-node (configure for node with core < 8)\n')
        elif line.startswith('    dcs_exists_action:'):
            dst.write('    dcs_exists_action: abort\n')
        elif line.startswith('    node_dns_server:'):
            dst.write('    node_dns_server: none\n')
        elif line.startswith('    node_admin_pks:'):
            dst.write(line.replace('node_admin_pks:   ', 'node_admin_pks: []'))
            skip_line = True
        elif line.startswith('        vip_'):
            dst.write('#' + line)
        else:
            dst.write(line)

# oltp replace tiny to oltp
dst_path = os.path.join(script_dir, "pigsty-oltp.yml")
print("generate %s" % dst_path)
with open(dst_path, 'w') as dst:
    skip_line = False
    for i, line in enumerate(raw_config):
        if skip_line:
            skip_line = False
            continue
        if block_start <= i < block_end:
            continue
            # dst.write('#' + line)
        elif line.startswith('# Desc'):
            dst.write('# Desc      :   Pigsty 1-oltp-node (configure for node with core >= 8)\n')
        elif line.startswith('    dcs_exists_action:'):
            dst.write('    dcs_exists_action: abort\n')
        elif line.startswith('    node_dns_server:'):
            dst.write('    node_dns_server: none\n')
        elif line.startswith('    node_admin_pks:'):
            dst.write(line.replace('node_admin_pks:   ', 'node_admin_pks: []'))
            skip_line = True
        elif line.startswith('        vip_'):
            dst.write('#' + line)
        elif 'pg_conf' in line or 'node_tune' in line:
            dst.write(line.replace('tiny', 'oltp'))
        else:
            dst.write(line)
