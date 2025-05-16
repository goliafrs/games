#!/bin/bash

SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
source $SCRIPT_DIR/_variables.sh
source $SCRIPT_DIR/_commands.sh

function help() {
  echo "Usage: $0 <game> <command>"
  echo ""
  echo "Available games:"
  for game in "${GAMES[@]}"; do
    echo "  $game"
  done
  echo ""
  echo "Available commands:"
  echo "  start     - Starts game server containers in detached mode and follows logs."
  echo "  stop      - Stops running game server containers."
  echo "  restart   - Restarts game server containers (stop and start)."
  echo "  logs      - Follows logs of game server containers in real-time."
  echo "  attach    - Attaches to the running game server container using bash."
  echo "  destroy   - Stops and removes the game server container."
  echo "  cleanup   - Removes all unused game server images, containers, networks, and volumes."
  echo "  reset     - Stops, removes the container, clears data, and starts the container again."
  echo "  backup    - Creates a backup of data and uploads it to remote storage."
  echo "  init      - Sets execute permissions on the script and creates a symbolic link in the home directory."
  echo "  cron      - Adds a cron job to create a backup."
}

function handler() {
  case "$1" in
    start)
      start
      ;;
    stop)
      stop
      ;;
    restart)
      restart
      ;;
    logs)
      logs
      ;;
    attach)
      attach
      ;;
    destroy)
      destroy
      ;;
    cleanup)
      cleanup
      ;;
    reset)
      reset
      ;;
    backup)
      backup
      ;;
    init)
      init
      ;;
    cron)
      cron
      ;;
    *)
      help
      ;;
  esac
}
