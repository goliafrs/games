#!/bin/bash

SERVER_DIR="/root/dayz"
SERVER_KEYS_DIR="$SERVER_DIR/keys"
STEAM_WORKSHOP_CONTENT_DIR_PART="Steam/steamapps/workshop/content"

STEAM_SERVER_APP_ID="223350"
STEAM_CLIENT_APP_ID="221100"
STEAM_GUARD_CMD=""
if [ -n "$STEAM_GUARD_CODE" ]; then
  STEAM_GUARD_CMD="+set_steam_guard_code $STEAM_GUARD_CODE"
fi

LAST_UPDATE_FILE="$SERVER_DIR/.last_update"
LAST_MODS_FILE="$SERVER_DIR/.last_mods"

function make_dirs() {
  if [ ! -d "$SERVER_DIR" ]; then
    mkdir -p $SERVER_DIR
  fi
}

function init_server_cfg() {
  local cfg="$SERVER_DIR/${CONFIG_FILE:-serverDZ.cfg}"

  if [ ! -f "$cfg" ]; then
    echo "Config file $cfg does not exist, creating new config file..."
    touch "$cfg"
  fi

  cat > "$cfg" <<EOF
hostname                    = "${HOSTNAME}";
description                 = "${DESCRIPTION}";

password                    = "${PASSWORD}";
passwordAdmin               = "${PASSWORD_ADMIN}";

enableWhitelist             = ${ENABLE_WHITELIST};
disableBanlist              = ${DISABLE_BANLIST};
disablePrioritylist         = ${DISABLE_PRIORITYLIST};

maxPlayers                  = ${MAX_PLAYERS};

verifySignatures            = ${VERIFY_SIGNATURES};
forceSameBuild              = ${FORCE_SAME_BUILD};

disableVoN                  = ${DISABLE_VON};
vonCodecQuality             = ${VON_CODEC_QUALITY};

disable3rdPerson            = ${DISABLE_3RD_PERSON};
disableCrosshair            = ${DISABLE_CROSSHAIR};
disablePersonalLight        = ${DISABLE_PERSONAL_LIGHT};
lightingConfig              = "${LIGHTING_CONFIG}";

serverTime                  = "${SERVER_TIME}";
serverTimeAcceleration      = ${SERVER_TIME_ACCELERATION};
serverNightTimeAcceleration = ${SERVER_NIGHT_TIME_ACCELERATION};
serverTimePersistent        = ${SERVER_TIME_PERSISTENT};

guaranteedUpdates           = ${GUARANTEED_UPDATES};

loginQueueConcurrentPlayers = ${LOGIN_QUEUE_CONCURRENT_PLAYERS};
loginQueueMaxPlayers        = ${LOGIN_QUEUE_MAX_PLAYERS};

instanceId                  = ${INSTANCE_ID};

storageAutoFix              = ${STORAGE_AUTO_FIX};

class Missions
{
    class DayZ
    {
        template            = "${TEMPLATE}";
    };
};
EOF
}

function init_globals_xml() {
  local xml="$SERVER_DIR/mpmissions/${TEMPLATE}/db/globals.xml"
  [ ! -f "$xml" ] && return 0

  xmlstarlet ed -L \
    -u '//var[@name="AnimalMaxCount"]/@value' -v "${ANIMAL_MAX_COUNT}" \
    -u '//var[@name="CleanupAvoidance"]/@value' -v "${CLEANUP_AVOIDANCE}" \
    -u '//var[@name="CleanupLifetimeDeadAnimal"]/@value' -v "${CLEANUP_LIFETIME_DEAD_ANIMAL}" \
    -u '//var[@name="CleanupLifetimeDeadInfected"]/@value' -v "${CLEANUP_LIFETIME_DEAD_INFECTED}" \
    -u '//var[@name="CleanupLifetimeDeadPlayer"]/@value' -v "${CLEANUP_LIFETIME_DEAD_PLAYER}" \
    -u '//var[@name="CleanupLifetimeDefault"]/@value' -v "${CLEANUP_LIFETIME_DEFAULT}" \
    -u '//var[@name="CleanupLifetimeLimit"]/@value' -v "${CLEANUP_LIFETIME_LIMIT}" \
    -u '//var[@name="CleanupLifetimeRuined"]/@value' -v "${CLEANUP_LIFETIME_RUINED}" \
    -u '//var[@name="FlagRefreshFrequency"]/@value' -v "${FLAG_REFRESH_FREQUENCY}" \
    -u '//var[@name="FlagRefreshMaxDuration"]/@value' -v "${FLAG_REFRESH_MAX_DURATION}" \
    -u '//var[@name="FoodDecay"]/@value' -v "${FOOD_DECAY}" \
    -u '//var[@name="IdleModeCountdown"]/@value' -v "${IDLE_MODE_COUNTDOWN}" \
    -u '//var[@name="IdleModeStartup"]/@value' -v "${IDLE_MODE_STARTUP}" \
    -u '//var[@name="InitialSpawn"]/@value' -v "${INITIAL_SPAWN}" \
    -u '//var[@name="LootDamageMax"]/@value' -v "${LOOT_DAMAGE_MAX}" \
    -u '//var[@name="LootDamageMin"]/@value' -v "${LOOT_DAMAGE_MIN}" \
    -u '//var[@name="LootProxyPlacement"]/@value' -v "${LOOT_PROXY_PLACEMENT}" \
    -u '//var[@name="LootSpawnAvoidance"]/@value' -v "${LOOT_SPAWN_AVOIDANCE}" \
    -u '//var[@name="RespawnAttempt"]/@value' -v "${RESPAWN_ATTEMPT}" \
    -u '//var[@name="RespawnLimit"]/@value' -v "${RESPAWN_LIMIT}" \
    -u '//var[@name="RespawnTypes"]/@value' -v "${RESPAWN_TYPES}" \
    -u '//var[@name="RestartSpawn"]/@value' -v "${RESTART_SPAWN}" \
    -u '//var[@name="SpawnInitial"]/@value' -v "${SPAWN_INITIAL}" \
    -u '//var[@name="TimeHopping"]/@value' -v "${TIME_HOPPING}" \
    -u '//var[@name="TimeLogin"]/@value' -v "${TIME_LOGIN}" \
    -u '//var[@name="TimeLogout"]/@value' -v "${TIME_LOGOUT}" \
    -u '//var[@name="TimePenalty"]/@value' -v "${TIME_PENALTY}" \
    -u '//var[@name="WorldWetTempUpdate"]/@value' -v "${WORLD_WET_TEMP_UPDATE}" \
    -u '//var[@name="ZombieMaxCount"]/@value' -v "${ZOMBIE_MAX_COUNT}" \
    -u '//var[@name="ZoneSpawnDist"]/@value' -v "${ZONE_SPAWN_DIST}" \
    "$xml"
}

function init_dayzsetting_xml() {
  local xml="$SERVER_DIR/dayzsetting.xml"
  [ ! -f "$xml" ] && return 0

  xmlstarlet ed -L \
    -u '//jobsystem/pc/@maxcores' -v "${CPU_COUNT}" \
    -u '//jobsystem/pc/@reservedcores' -v "${RESERVED_CORES}" \
    "$xml"
}

function update() {
  local now=$(date +%s)
  local last=0
  if [ -f "$LAST_UPDATE_FILE" ]; then
    last=$(cat "$LAST_UPDATE_FILE")
  fi
  if (( now - last < 24 * 3600 )); then
    echo "Skipping update, last update was less than 24 hours ago."
    return 0
  fi

  make_dirs
  steamcmd \
    +force_install_dir $SERVER_DIR \
    $STEAM_GUARD_CMD \
    +login "$STEAM_USER" "$STEAM_PASS" \
    +app_update $STEAM_SERVER_APP_ID \
    validate \
    +quit

  echo "$now" > "$LAST_UPDATE_FILE"
}

function update_mods() {
  [ -z "$MODS" ] && return 0
  [ -z "$MODS_IDS" ] && return 0

  local mods_state="${MODS}|${MODS_IDS}"
  local mods_changed=1

  if [ -f "$LAST_MODS_FILE" ]; then
    local last_mods_state
    last_mods_state=$(cat "$LAST_MODS_FILE")
    if [ "$mods_state" == "$last_mods_state" ]; then
      mods_changed=0
    fi
  fi

  IFS=';' read -ra MODS_LIST <<< "$MODS"
  IFS=';' read -ra MODS_IDS_LIST <<< "$MODS_IDS"

  if [ "${#MODS_LIST[@]}" -ne "${#MODS_IDS_LIST[@]}" ]; then
    echo "MODS and MODS_IDS count mismatch!"
    return 1
  fi

  # Проверяем наличие всех модов локально
  local need_download=0
  for i in "${!MODS_LIST[@]}"; do
    mod="${MODS_LIST[$i]}"
    mod_id="${MODS_IDS_LIST[$i]}"
    dst="$SERVER_DIR/$mod"
    if [ ! -d "$dst" ]; then
      need_download=1
      break
    fi
  done

  if [ $mods_changed -eq 0 ] && [ $need_download -eq 0 ]; then
    echo "No changes in mods, skipping download."
    return 0
  fi

  for i in "${!MODS_LIST[@]}"; do
    mod="${MODS_LIST[$i]}"
    mod_id="${MODS_IDS_LIST[$i]}"
    echo "Downloading $mod (Workshop ID: $mod_id)..."
    steamcmd \
      $STEAM_GUARD_CMD \
      +login "$STEAM_USER" "$STEAM_PASS" \
      +workshop_download_item $STEAM_CLIENT_APP_ID $mod_id \
      validate \
      +quit

    src1="/root/${STEAM_WORKSHOP_CONTENT_DIR_PART}/${STEAM_CLIENT_APP_ID}/${mod_id}"
    src2="/root/.local/share/${STEAM_WORKSHOP_CONTENT_DIR_PART}/${STEAM_CLIENT_APP_ID}/${mod_id}"

    dst="$SERVER_DIR/$mod"
    rm -rf "$dst"
    mkdir -p "$dst"

    if [ -d "$src1" ]; then
      src="$src1"
    elif [ -d "$src2" ]; then
      src="$src2"
    else
      echo "Error: Mod directory not found for $mod (ID: $mod_id)."
    fi

    cp -r "$src/"* "$dst"/
    echo "Downloaded $mod to $dst"

    mod_keys_dir="$SERVER_DIR/$mod/keys"
    if [ -d "$mod_keys_dir" ]; then
      cp -n "$mod_keys_dir"/* "$SERVER_KEYS_DIR"/ 2>/dev/null || true
      echo "Copied keys for $mod to $SERVER_KEYS_DIR"
    fi
  done

  echo "$mods_state" > "$LAST_MODS_FILE"
}

function start() {
  cd $SERVER_DIR
  local mods_arg=""
  if [ -n "$MODS" ]; then
    mods_arg="-mod=${MODS}"
  fi

  local config_file="${CONFIG_FILE:-serverDZ.cfg}"
  local port="${PORT:-2302}"
  local bePath="${BE_PATH:-battleye}"
  local cpu_count="${CPU_COUNT:-$(nproc)}"
  local limit_fps="${LIMIT_FPS:-1}"
  local profiles="${PROFILES:-profiles}"
  local doLogs_flag=""
  local adminLog_flag=""
  local netLog_flag=""
  local freezeCheck_flag=""
  local script_debug_flag=""
  local script_debug_level_flag=""
  local file_patching_flag=""
  local mission_flag=""
  local name_flag=""

  [ "${DO_LOGS:-1}" = "1" ] && doLogs_flag="-doLogs"
  [ "${ADMIN_LOG:-1}" = "1" ] && adminLog_flag="-adminLog"
  [ "${NET_LOG:-1}" = "1" ] && netLog_flag="-netLog"
  [ "${FREEZE_CHECK:-1}" = "1" ] && freezeCheck_flag="-freezeCheck"
  [ "${SCRIPT_DEBUG:-0}" = "1" ] && script_debug_flag="-scriptDebug"
  [ -n "${SCRIPT_DEBUG_LEVEL}" ] && script_debug_level_flag="-scriptDebugLevel=${SCRIPT_DEBUG_LEVEL}"
  [ "${FILE_PATCHING:-0}" = "1" ] && file_patching_flag="-filePatching"
  [ -n "${MISSION}" ] && mission_flag="-mission=${MISSION}"
  [ -n "${NAME}" ] && name_flag="-name=${NAME}"
  [ -n "${LIMIT_FPS}" ] && limit_fps_flag="-limitFPS=${LIMIT_FPS}"

  local dayZ_cmd="./DayZServer \
    -config=\"${config_file}\" \
    -port=\"${port}\" \
    -bePath=\"${bePath}\" \
    -cpuCount=\"${cpu_count}\" \
    -limitFPS=\"${limit_fps}\" \
    -profiles=\"${profiles}\" \
    $doLogs_flag \
    $adminLog_flag \
    $netLog_flag \
    $freezeCheck_flag \
    $script_debug_flag \
    $script_debug_level_flag \
    $file_patching_flag \
    $mission_flag \
    $name_flag \
    $mods_arg"

  echo "Command to start DayZ server:"
  echo "$dayZ_cmd"

  echo "Starting DayZ server..."
  eval "$dayZ_cmd" || {
    echo "Failed to start DayZ server."
    exit 1
  }
}

function stop() {
  pkill -f DayZServer || true
}

function restart() {
  stop
  start
}

function init() {
  init_server_cfg
  init_globals_xml
  init_dayzsetting_xml
}

case "$1" in
init)
  init
  ;;
start)
  update
  update_mods
  init
  start
  ;;
stop)
  stop
  ;;
restart)
  restart
  ;;
update)
  update
  update_mods
  ;;
*)
  exec "$@"
  ;;
esac
