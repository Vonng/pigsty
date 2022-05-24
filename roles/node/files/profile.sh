#!/bin/bash
#==============================================================#
# Environment
export EDITOR="vi"
export PAGER="less"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
#--------------------------------------------------------------#
# Bash opts
shopt -s nocaseglob # case-insensitive globbing
shopt -s cdspell    # auto-correct typos in cd
set -o pipefail     # pipe fail when component fail
shopt -s histappend # append to history rather than overwrite
for option in autocd globstar; do
	shopt -s "$option" 2>/dev/null
done
#--------------------------------------------------------------#
# Bash settings
export MANPAGER="less -X"
export HISTSIZE=10000
export HISTFILESIZE=$HISTSIZE
export HISTCONTROL=ignoredups
export HISTIGNORE="l:ls:cd:cd -:pwd:exit:date:* --help"
#--------------------------------------------------------------#
# PATH
[ -d ${PGHOME:=/usr/pgsql} ] && export PGHOME || unset PGHOME
[ -d ${PGDATA:=/pg/data} ] && export PGDATA || unset PGDATA
#--------------------------------------------------------------#
# Path builder
[ ! -z "$PGHOME" ] && PATH=$PGHOME/bin:$PATH
[ -d "/pg/bin" ] && PATH=/pg/bin:$PATH
#--------------------------------------------------------------#
# Path dedupe
if [ -n "$PATH" ]; then
	old_PATH=$PATH:
	PATH=
	while [ -n "$old_PATH" ]; do
		x=${old_PATH%%:*}
		case $PATH: in
		*:"$x":*) ;;
		*) PATH=$PATH:$x ;;
		esac
		old_PATH=${old_PATH#*:}
	done
	PATH=${PATH#:}
	unset old_PATH x
fi
#--------------------------------------------------------------#
