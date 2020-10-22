#!/bin/env bash

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
export HISTSIZE=65535
export HISTFILESIZE=$HISTSIZE
export HISTCONTROL=ignoredups
export HISTIGNORE="l:ls:cd:cd -:pwd:exit:date:* --help"
#--------------------------------------------------------------#
# Prompt
export PS1="\[\033]0;\w\007\]\[\]\n\[\e[1;36m\][\D{%m-%d %T}] \[\e[1;31m\]\u\[\e[1;33m\]@\H\[\e[1;32m\]:\w \n\[\e[1;35m\]\$ \[\e[0m\]"
#--------------------------------------------------------------#
# PATH
[ -d ${GOROOT:=/usr/local/go} ] && export GOROOT || unset GOROOT
[ -d ${GOPATH:=${HOME}/go} ] && export GOPATH || unset GOPATH
[ -d ${PGHOME:=/usr/pgsql} ] && export PGHOME || unset PGHOME
[ -d ${PGDATA:=/pg/data} ] && export PGDATA || unset PGDATA
#--------------------------------------------------------------#
# Path builder
[ ! -z "$GOROOT" ] && PATH=$GOROOT/bin:$PATH
[ ! -z "$GOPATH" ] && PATH=$GOPATH/bin:$PATH
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
# aliases & functions
alias c="clear"
alias s="systemctl"
alias p="psql"
alias q="exit"
alias j="jobs"
alias k="kubectl"
alias d="docker"
alias h="history"
function v() {
	[ $# -eq 0 ] && vi . || vi $@
}

alias hg="history | grep --color=auto "
alias py="python"
alias dk="docker"
alias cl="clear"
alias clc="clear"
alias rf="rm -rf"
alias ax="chmod a+x"
alias sa="sudo su - root"
alias sp="sudo su - postgres"
alias adm="sudo su - admin"
alias pp="sudo su - postgres"
alias sc='sudo systemctl'
alias st="sudo systemctl status "
alias pg="/usr/pgsql/bin/pg_ctl"
alias pt='patronictl -c /pg/bin/patroni.yml'
alias ntpsync="sudo ntpdate pool.ntp.org"

#--------------------------------------------------------------#
# ls corlor
[ ls --color ] >/dev/null 2>&1 && colorflag="--color" || colorflag="-G"
[ "${TERM}" != "dumb" ] && export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:\ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'
alias sl=ls
alias ll="ls -lh ${colorflag}"
alias l="ls -lh ${colorflag}"
alias la="ls -lha ${colorflag}"
alias lsa="ls -a ${colorflag}"
alias ls="command ls ${colorflag}"
alias lsd="ls -lh ${colorflag} | grep --color=never '^d'" # List only directories
alias ~="cd ~"
alias ..="cd .."
alias cd..="cd .."
alias ...="cd ../.."
alias cd...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
alias now='date +"DATE: %Y-%m-%d  TIME: %H:%M:%S  EPOCH: %s"'
alias today='date +"%Y%m%d "'
alias suod='sudo '
alias map="xargs -n1"
alias gst="git status"
alias gci="git commit"
alias gp="git pull"
alias gpu="git push origin master"
alias yaml2json='ruby -ryaml -rjson -e "puts JSON.pretty_generate(YAML.load(STDIN.read))"'
alias json2yaml='ruby -ryaml -rjson -e "puts YAML.dump(JSON.parse(STDIN.read))"'
alias urlenc='python -c "import sys, urllib as ul; print(ul.quote(sys.argv[1]));"'
alias urldec='python -c "import sys, urllib as ul; print(ul.unquote(sys.argv[1]));"'
alias b64enc='python -c "import sys,base64 as b;print(b.b64encode(sys.argv[1]));"'
alias b64dec='python -c "import sys,base64 as b;print(b.b64decode(sys.argv[1]));"'
#--------------------------------------------------------------#
# utils
function tz() {
	if [ -t 0 ]; then # argument
		tar -zcf "$1.tar.gz" "$@"
	else # pipe
		gzip
	fi
}
function tx() {
	if [ -t 0 ]; then # argument
		tar -xf $@
	else # pipe
		tar -x -
	fi
}
function log_debug() {
	[[ -t 2 ]] && printf "\033[0;34m[$(date "+%Y-%m-%d %H:%M:%S")][$HOSTNAME][DEBUG] $*\033[0m\n" >&2 ||
		printf "[$(date "+%Y-%m-%d %H:%M:%S")][$HOSTNAME][DEBUG] $*\n" >&2
}
function log_info() {
	[[ -t 2 ]] && printf "\033[0;32m[$(date "+%Y-%m-%d %H:%M:%S")][$HOSTNAME][INFO] $*\033[0m\n" >&2 ||
		printf "[$(date "+%Y-%m-%d %H:%M:%S")][$HOSTNAME][INFO] $*\n" >&2
}
function log_warn() {
	[[ -t 2 ]] && printf "\033[0;33m[$(date "+%Y-%m-%d %H:%M:%S")][$HOSTNAME][WARN] $*\033[0m\n" >&2 ||
		printf "[$(date "+%Y-%m-%d %H:%M:%S")][$HOSTNAME][INFO] $*\n" >&2
}
function log_error() {
	[[ -t 2 ]] && printf "\033[0;31m[$(date "+%Y-%m-%d %H:%M:%S")][$HOSTNAME][ERROR] $*\033[0m\n" >&2 ||
		printf "[$(date "+%Y-%m-%d %H:%M:%S")][$HOSTNAME][INFO] $*\n" >&2
}
#==============================================================#
