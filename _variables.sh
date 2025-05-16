#!/bin/bash

SCRIPT_DIR=$(dirname ${BASH_SOURCE[0]})
CURRENT_DIR=$(basename $SCRIPT_DIR)
SERVER_NAME=Server
ARCHIVE_NAME=$SERVER_NAME.zip
R_CLONE_STORAGE=google-drive
SAVE_PATHS=("./")

mapfile -t GAMES < <(find "$SCRIPT_DIR" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | grep -v "^$CURRENT_DIR$" | sort)
mapfile -t COMMANDS < <(grep -E '^\s*function\s+\w+|^\s*\w+\s*\(\)' "$SCRIPT_DIR/_commands.sh" | awk '{print $2}' | sed 's/()//')