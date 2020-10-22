#!/usr/bin/env bash

# make sure that:
# * etcd is dead
# * conf and data dir removed
# * conf and data dir recreate


# graceful shutdown
if ps -u etcd -o command | grep -q 'etcd' ; then
	/usr/bin/etcd leave
	systemctl stop etcd
fi

# kill if still exists
if ps -u etcd -o command | grep -q 'etcd' ; then
	sleep 2
	ps -u etcd -o pid:1,command | grep 'etcd' | awk '{print $1}' | xargs kill -9
fi

# remove etcd config dir and data dir
rm -rf /var/lib/etcd/data /etc/etcd/
mkdir /var/lib/etcd/data /etc/etcd/
chown etcd /var/lib/etcd/data /etc/etcd/
chmod 0775 /var/lib/etcd/data /etc/etcd/

# guaranteed success
exit 0
