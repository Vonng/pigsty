#!/usr/bin/env bash

# disable transparent hugepage
if (! grep -q 'disable transparent hugepage' /etc/rc.local); then
	echo 'never' >/sys/kernel/mm/transparent_hugepage/enabled
	echo 'never' >/sys/kernel/mm/transparent_hugepage/defrag
	cat >>/etc/rc.local <<-EOF
		# disable transparent hugepage
		echo 'never' > /sys/kernel/mm/transparent_hugepage/enabled
		echo 'never' > /sys/kernel/mm/transparent_hugepage/defrag
	EOF
	chmod +x /etc/rc.d/rc.local
fi
exit 0
