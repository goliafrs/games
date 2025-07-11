#!/bin/bash

SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
source $SCRIPT_DIR/_variables.sh

function start() {
  docker compose --file $COMPOSE_FILE up --detach --build
  logs
}

function stop() {
  docker compose --file $COMPOSE_FILE down
}

function restart() {
  stop
  start
}

function logs() {
  docker compose --file $COMPOSE_FILE logs --follow --no-log-prefix
}

function attach() {
  docker exec --interactive --tty $CONTAINER_NAME /bin/bash
}

function destroy() {
  stop
  docker compose --file $COMPOSE_FILE rm --force
}

function cleanup() {
  docker system prune --all --force --volumes
}

function post_reset() {
  case $GAME in
    "avorion")
      GALAXY_DIR=$DATA_DIR/galaxies/$SERVER_NAME
      mkdir -p $GALAXY_DIR
      cd $GAME_DIR/init
      cp whitelist.txt group-whitelist.txt server.ini modconfig.lua $GALAXY_DIR/
      ;;
    "minecraft-vault-hunters")
      cp $GAME_DIR/init/server.properties $DATA_DIR
      ;;
  esac
}

function reset() {
  stop
  destroy
  cleanup
  sudo rm -rf $DATA_DIR/*
  post_reset
  start
}

function backup() {
  if ! command -v zip &> /dev/null
  then
    sudo apt update
    sudo apt install -y zip
  fi

  if ! command -v rclone &> /dev/null
  then
    echo "rclone is not installed. Please install rclone and configure the storage."
    exit 1
  fi

  if ! rclone listremotes | grep -q "^$R_CLONE_STORAGE:"
  then
    echo "rclone storage '$R_CLONE_STORAGE' is not configured. Please configure rclone storage."
    exit 1
  fi

  cd $DATA_DIR
  zip -r $DATA_DIR/$ARCHIVE_NAME "${SAVE_PATHS[@]}"
  if [ $? -ne 0 ]; then
    echo "Failed to create backup archive."
    exit 1
  fi

  rclone copy $DATA_DIR/$ARCHIVE_NAME $REMOTE_DIR --drive-chunk-size=256M --progress

  rm $DATA_DIR/$ARCHIVE_NAME
}

function init() {
  cd $GAME_DIR
  sudo chmod u+x ./$GAME.sh
  ln -s $GAME_DIR/$GAME.sh ~/$GAME.sh
}

function cron() {
  (crontab -l 2>/dev/null | grep -F "$CRON_JOB") || (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
  (crontab -l 2>/dev/null | grep -F "$CRON_JOB_1") || (crontab -l 2>/dev/null; echo "$CRON_JOB_1") | crontab -
}
