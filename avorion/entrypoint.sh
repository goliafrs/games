#!/bin/bash

GALAXY_PATH="/root/.avorion/galaxies/$GALAXY_NAME"
WHITELIST_PATH="$GALAXY_PATH/whitelist.txt"
INIT_PATH="/srv/avorion/init"

if [ ! -d "$GALAXY_PATH" ]; then
  echo "Creating galaxy folder: $GALAXY_PATH"
  mkdir -p "$GALAXY_PATH"
fi

copy_if_not_exists() {
  local src_file=$1
  local dest_file=$2

  if [ ! -f "$dest_file" ]; then
    echo "Copying $src_file to $dest_file"
    cp "$src_file" "$dest_file"
  fi
}

copy_if_not_exists "$INIT_PATH/server.ini" "$GALAXY_PATH/server.ini"
copy_if_not_exists "$INIT_PATH/modconfig.lua" "$GALAXY_PATH/modconfig.lua"

if [ ! -f "$WHITELIST_PATH" ]; then
  echo "Creating whitelist file: $WHITELIST_PATH"
  touch "$WHITELIST_PATH"
fi

if [ -n "$WHITELIST" ]; then
  IFS=',' read -ra WHITELIST_ARRAY <<< "$WHITELIST"
  for USER_ID in "${WHITELIST_ARRAY[@]}"; do
    if ! grep -q "$USER_ID" "$WHITELIST_PATH"; then
      echo "Adding user ID: $USER_ID to $WHITELIST_PATH"
      echo "$USER_ID" >> "$WHITELIST_PATH"
    fi
  done
fi

exec /srv/avorion/bin/AvorionServer --galaxy-name "$GALAXY_NAME"