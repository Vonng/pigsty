#!/usr/bin/env bash

# setup disk prefetch
if (! grep -q 'disk prefetch' /etc/rc.local); then
	cat >>/etc/rc.local <<-EOF
		# disk prefetch
		blockdev --setra 16384 $(echo $(blkid | awk -F':' '$1!~"block"{print $1}'))
	EOF
	chmod +x /etc/rc.d/rc.local
fi
exit 0
