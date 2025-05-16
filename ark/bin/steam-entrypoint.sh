#!/bin/bash

set -e

[[ -z "${DEBUG}" ]] || [[ "${DEBUG,,}" = "false" ]] || [[ "${DEBUG,,}" = "0" ]] || set -x

if [[ "$(whoami)" != "${STEAM_USER}" ]]; then
  echo "Run this script as steam-user"
  exit 1
fi

function update_on_start() {
  if [[ "${UPDATE_ON_START}" != "true" ]]; then
    return
  fi

  echo "Preparing to update on start..."

  # auto checks if a update is needed, if yes, then update the server or mods
  # (otherwise it just does nothing)
  ${ARKMANAGER} update --verbose --update-mods --backup --no-autostart
}

function create_missing_dir() {
  for DIRECTORY in ${@}; do
    [[ -n "${DIRECTORY}" ]] || return
    if [[ ! -d "${DIRECTORY}" ]]; then
      echo "Creating ${DIRECTORY}..."
      mkdir -p "${DIRECTORY}"
    fi
  done
}

function copy_missing_file() {
  SOURCE="${1}"
  DESTINATION="${2}"

  if [[ ! -f "${DESTINATION}" ]]; then
    echo "Copying ${SOURCE} to ${DESTINATION}..."
    cp -a "${SOURCE}" "${DESTINATION}"
  fi
}

args=("$*")
if [[ "${ENABLE_CROSSPLAY}" == "true" ]]; then
  args=('--arkopt,-crossplay' "${args[@]}")
fi
if [[ "${DISABLE_BATTLEYE}" == "true" ]]; then
  args=('--arkopt,-NoBattlEye' "${args[@]}")
fi

ARKMANAGER="$(command -v arkmanager)"

if [[ ! -x "${ARKMANAGER}" ]]; then
  echo "Arkamanger is missing"
  exit 1
fi

echo "_______________________________________"
echo ""
echo "# Date:        $(date)"
echo "# Manager:     ${ARKMANAGER}"
echo "# User:        ${STEAM_USER}:$(id -u)"
echo "# Args:        ${args[*]}"
echo "_______________________________________"

cd "${ARK_SERVER_VOLUME}"

create_missing_dir "${ARK_SERVER_VOLUME}/log" "${ARK_SERVER_VOLUME}/backup" "${ARK_SERVER_VOLUME}/staging"

copy_missing_file "${TEMPLATE_DIRECTORY}/arkmanager.cfg" "${ARK_TOOLS_DIR}/arkmanager.cfg"
copy_missing_file "${TEMPLATE_DIRECTORY}/main.cfg" "${ARK_TOOLS_DIR}/instances/main.cfg"
copy_missing_file "${TEMPLATE_DIRECTORY}/crontab" "${ARK_SERVER_VOLUME}/crontab"

[[ -L "${ARK_SERVER_VOLUME}/Game.ini" ]] || ln -s ./server/ShooterGame/Saved/Config/LinuxServer/Game.ini Game.ini
[[ -L "${ARK_SERVER_VOLUME}/GameUserSettings.ini" ]] || ln -s ./server/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini GameUserSettings.ini

if [[ ! -d ${ARK_SERVER_VOLUME}/server ]] || [[ ! -f ${ARK_SERVER_VOLUME}/server/version.txt ]]; then
  echo "No game files found. Installing..."

  create_missing_dir \
    "${ARK_SERVER_VOLUME}/server/ShooterGame/Saved/SavedArks" \
    "${ARK_SERVER_VOLUME}/server/ShooterGame/Content/Mods" \
    "${ARK_SERVER_VOLUME}/server/ShooterGame/Binaries/Linux"

  touch "${ARK_SERVER_VOLUME}/server/ShooterGame/Binaries/Linux/ShooterGameServer"
  chmod +x "${ARK_SERVER_VOLUME}/server/ShooterGame/Binaries/Linux/ShooterGameServer"

  ${ARKMANAGER} install --dots
fi

if [[ -n "${GAME_MOD_IDS}" ]]; then
  echo "Installing mods: ${GAME_MOD_IDS}..."

  for MOD_ID in ${GAME_MOD_IDS//,/ }; do
    if [[ -d "${ARK_SERVER_VOLUME}/server/ShooterGame/Content/Mods/${MOD_ID}" ]]; then
      echo "Mod ${MOD_ID} installed."
      continue
    fi

    ${ARKMANAGER} installmod "${MOD_ID}" --dots
  done
fi

update_on_start

exec "${ARKMANAGER}" run --dots ${args[@]}