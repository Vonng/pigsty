#!/usr/bin/env bash

modprobe softdog
chown postgres /dev/watchdog
exit 0
