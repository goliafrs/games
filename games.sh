#!/bin/bash

SCRIPT_DIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
source $SCRIPT_DIR/_variables.sh
source $SCRIPT_DIR/_commands.sh

GAME=$1
COMMAND=$2

if [ -z $GAME ]; then
  echo -e "\033[1;30mUsage:\033[0m \033[1;34mgames\033[0m \033[1;32m<game>\033[0m \033[1;35m[command]\033[0m"
  echo -e "\033[1;30mAvailable games:\033[0m"
  printf "\033[1;32m%s\n\033[0m" "${GAMES[@]}"
  echo ""
  echo -e "\033[1;30mCurrently running game servers:\033[0m"
  docker ps --format "table {{.Names}}\t{{.Image}}" | grep -E "$(IFS=\|; echo "${GAMES[*]}")" || echo -e "\033[0;36mNo game servers are currently running.\033[0m"
  exit 0
fi
if [ -z $COMMAND ]; then
  COMMAND=restart
fi
if [[ ! " ${GAMES[@]} " =~ " ${GAME} " ]]; then
  echo -e "\033[1;31mGame '\033[1;32m$GAME\033[1;31m' not found.\033[0m"
  echo -e "\033[1;30mAvailable games:\033[0m"
  printf "\033[1;32m%s\n\033[0m" "${GAMES[@]}"
  exit 1
fi
if [[ ! " ${COMMANDS[@]} " =~ " ${COMMAND} " ]]; then
  echo -e "\033[1;31mCommand '\033[1;35m$COMMAND\033[1;31m' not found.\033[0m"
  echo -e "\033[1;30mAvailable commands:\033[0m"
  printf "\033[1;35m%s\n\033[0m" "${COMMANDS[@]}"
  exit 1
fi

CONTAINER_NAME=$GAME
GAME_DIR=$SCRIPT_DIR/$GAME
DATA_DIR=$GAME_DIR/data
COMPOSE_FILE=$GAME_DIR/docker-compose.yml
REMOTE_DIR=$R_CLONE_STORAGE:/games/$GAME
CRON_JOB="0 * * * * $SCRIPT_DIR/games.sh $GAME backup"
CRON_JOB_1="30 6 * * * $SCRIPT_DIR/games.sh $GAME restart"

case $GAME in
  "ark")
    SAVE_PATHS=(
      "./GameUserSettings.ini"
      "./Game.ini"
      "./server/ShooterGame/Saved"
    )
    ;;
esac

$COMMAND