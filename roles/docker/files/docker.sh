#!/bin/sh
# copy this file to /etc/profile.d/docker.sh

if [ -x "$(command -v docker)" ]; then
  alias dc="docker compose"
  alias d="docker"
  alias dcc='docker container'
  alias di="docker image"
  alias dii='docker image inspect'
  alias diis='docker image inspect -f "Id:{{.Id}} {{println}}\
Created: {{.Created}} {{println}}\
Size: {{.Size}} {{println}}\
RepoDigests: {{range .RepoDigests}}{{println}}  {{.}}{{end}} {{println}}\
RepoTags: {{range .RepoTags}}{{println}}  {{.}}{{end}} {{println}}\
Layers: {{range .RootFS.Layers}}{{println}}  {{.}}{{end}} {{println}}\
Labels: {{json .Config.Labels}}"'
  alias dp="docker ps -a"
  alias dps='docker ps --format "table {{.Image}}\t{{.Command}}\t{{.RunningFor}}\t{{.Status}}\t{{.Names}}\t{{.Mounts}}"'
  alias dv='docker volume'

  if [ -f /etc/bash_completion.d/docker ] && ! type -f __docker_alias_completion_ &>/dev/null ; then
    source /etc/bash_completion.d/docker
    complete -F _docker d
    complete -F _alias_dcc_completion dcc
    complete -F _alias_di_completion di
    complete -F _alias_dii_completion dii
    complete -F _alias_dii_completion diis
    complete -F _alias_dv_completion dv

    docker_alias_list="dc dcc di dp dps dst dv"
    docker_alias_list2="dii diis"

    # ========== docker container ==========
    subcommands_container=""
    subcommands_container2=() # ("attach" "commit" ...)
    _alias_dcc_completion() {
      if [ -z "$subcommands_container" ]; then
        subcommands_container=$(docker container --help | grep -oP '^\s+\K\w+') # ("attach commit ...")
        for cmd in $subcommands_container; do
          subcommands_container2+=("$cmd")
        done
      fi
      __docker_alias_completion_ container "$subcommands_container"
    }

    # ========== docker image ==========
    subcommands_image=""
    subcommands_image2=() # ("build" "history" ...)
    _alias_di_completion() {
      if [ -z "$subcommands_image" ]; then
        subcommands_image=$(docker image --help | grep -oP '^\s+\K\w+') # ("build history ...")
        for cmd in $subcommands_image; do
          subcommands_image2+=("$cmd")
        done
      fi
      __docker_alias_completion_ image "$subcommands_image"
    }

    # ========== docker image inspect ==========
    _alias_dii_completion() {
      __docker_alias_completion2_ image inspect
    }

    # ========== docker volume ==========
    subcommands_volume=""
    subcommands_volume2=()
    _alias_dv_completion() {
      if [ -z "$subcommands_volume" ]; then
        subcommands_volume=$(docker volume --help | grep -oP '^\s+\K\w+')
        for cmd in $subcommands_volume; do
          subcommands_volume2+=("$cmd")
        done
      fi
      __docker_alias_completion_ volume "$subcommands_volume"
    }


    __docker_alias_completion_() {
      local command="$1"
      local subcommands="$2"
      local cur prev words cword
      _get_comp_words_by_ref -n : cur prev words cword
      # cur="${COMP_WORDS[COMP_CWORD]}"
      if [[ $cword -eq 0 ]]; then return; fi

      if [[ " ${docker_alias_list[@]} " =~ " $prev "  ]]; then
        COMPREPLY=( $(compgen -W "$subcommands" -- "${cur}") )
      else
        cword=$((cword + 1))
        words[0]=docker
        if [[ -n "${words[1]}" ]]; then
          words[2]=${words[1]}
        fi
        words[1]=$command
        __docker_subcommands "$subcommands"
      fi
    }

    __docker_alias_completion2_() {
      local command="$1"
      local subcommand="$2"
      local cur
      _get_comp_words_by_ref -n : cur
      local completions_func=_docker_${command}_${subcommand//-/_}
      declare -F "$completions_func" >/dev/null && "$completions_func"
      return 0
    }

  fi
fi

# vim:ts=2:sw=2
