#!/usr/bin/env bash

# use static ip and dns nameserver
for interface in $(ls /etc/sysconfig/network-scripts/ifcfg-*); do
	if (! grep -q 'PEERDNS' $interface); then
		echo 'PEERDNS=no' >> $interface
	else
		sed -i s/PEERDNS=.*/PEERDNS=no/ $interface;
	fi
done
