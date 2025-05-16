#!/bin/bash

SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
source $SCRIPT_DIR/_variables.sh

main() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  if [[ ${COMP_CWORD} == 1 ]]; then
    COMPREPLY=( $(compgen -W "${GAMES}" -- ${cur}) )
    return 0
  fi

  if [[ ${COMP_CWORD} == 2 ]]; then
    COMPREPLY=( $(compgen -W "${COMMANDS}" -- ${cur}) )
    return 0
  fi
}

complete -F main games