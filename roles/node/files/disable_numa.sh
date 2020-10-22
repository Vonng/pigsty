#!/usr/bin/env bash

if ( ! type -f grubby &>/dev/null  ); then
	yum install -q -y grubby
fi
grubby --update-kernel=/boot/vmlinuz-$(uname -r) --args="numa=off transparent_hugepage=never"
exit 0
