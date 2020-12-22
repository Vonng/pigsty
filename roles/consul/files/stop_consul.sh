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

# guaranteed success
exit 0
