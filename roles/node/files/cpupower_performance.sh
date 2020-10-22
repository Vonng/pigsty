#!/usr/bin/env bash

# set cpu power mode to performance mode if applicable
if (cpupower frequency-info --governors | grep -q "performance"); then
	echo "cpupower performance governor is supported"
	cpupower frequency-set --governor performance
else
	echo "cpupower performance governor not available"
fi
exit 0
