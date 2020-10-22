#!/usr/bin/env bash

# make sure that:
# * consul is dead
# * conf and data dir removed
# * conf and data dir recreate


# graceful shutdown
if ps -u consul -o command | grep -q 'consul agent' ; then
	/usr/bin/consul leave
	systemctl stop consul
fi

# kill if still exists
if ps -u consul -o command | grep -q 'consul agent' ; then
	sleep 2
	ps -u consul -o pid:1,command | grep 'consul agent' | awk '{print $1}' | xargs kill -9
fi

# remove consul config dir and data dir
rm -rf /var/lib/consul /etc/consul.d
mkdir /var/lib/consul /etc/consul.d
chown consul /var/lib/consul /etc/consul.d
chmod 0775 /var/lib/consul /etc/consul.d

# guaranteed success
exit 0
